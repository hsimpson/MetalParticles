//
//  Renderer.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

import Metal
import MetalKit
import Combine

class Renderer : NSObject, MTKViewDelegate {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let sampleCount: Int = 4
    var lastRenderTime: CFTimeInterval? = nil
    var currentTime: Double = 0
    let gpuLock = DispatchSemaphore(value: 1)
    let boxMesh: Mesh
    let crosshairMesh: Mesh
    var meshes: [Mesh] = []
    let camera: Camera
    let boxDimension: simd_float3
    var currentMousePos: simd_float2 = [0, 0]
    var particleCount: UInt32 = 20_000
    let computePipeline: ComputePipeline
    let statsObservable: StatsObservable
    var frameCount: UInt32 = 0
    var frameTimeSum: Double = 0
    var computeTimeSum: Double = 0
    var particleRenderParams: ParticleRenderParams
    let particleRenderParamBuffer: MetalBuffer
    
    init?(mtkView: MTKView, statsObservable: StatsObservable) throws {
        device = mtkView.device!
        self.statsObservable = statsObservable
        
        if (sampleCount > 1) {
            mtkView.sampleCount = sampleCount
        }
        
        commandQueue = device.makeCommandQueue()!
        
        let objectRenderPipeline = try RenderPipeline(device: device, metalKitView: mtkView, sampleCount: sampleCount, vertexFunction: "objectVertex", fragmentFunction: "objectFragment")
        let particleRenderPipeline = try RenderPipeline(device: device, metalKitView: mtkView, sampleCount: sampleCount, vertexFunction: "particleVertex", fragmentFunction: "particleFragment")
       
        
        camera = Camera(fovY: 45.0, aspectRatio: Float(mtkView.bounds.width / mtkView.bounds.height), zNear: 0.1, zFar: 1000, device: device)
        camera.position = [0, 0, 15]
        camera.updateMatrices()
        
        boxDimension = [8, 5, 5]
        let boxGeometry = BoxGeometry(dimension: boxDimension, device: device)
        boxMesh = Mesh(renderPipeline: objectRenderPipeline, geometry: boxGeometry, camera: camera, device: device)
        boxMesh.vertexBuffers.append(boxGeometry.vertexBuffer)
        
        
        let crosshairGeometry = CrosshairGeometry(dimension: [1, 1, 1], device: device)
        crosshairMesh = Mesh(renderPipeline: objectRenderPipeline, geometry: crosshairGeometry, camera: camera, device: device)
        crosshairMesh.vertexBuffers.append(crosshairGeometry.vertexBuffer)
        
        let particleGeometry = ParticleGeometry(particleCount: particleCount, boxDimension: boxDimension, device: device)
        let particleMesh = Mesh(renderPipeline: particleRenderPipeline, geometry: particleGeometry, camera: camera, device: device)
        particleMesh.vertexBuffers.append(particleGeometry.vertexBuffer)
        
        particleRenderParams = ParticleRenderParams(color: [1.0, 0.0, 0.0, 1.0], pointSize: 1.0)
        let paramsBuffer = device.makeBuffer(bytes: UnsafeRawPointer(&particleRenderParams), length: MemoryLayout<ParticleRenderParams>.stride, options: [])!
        particleRenderParamBuffer = MetalBuffer(buffer: paramsBuffer, offset: 0, index: 3)
        particleMesh.vertexBuffers.append(particleRenderParamBuffer)
        
        // create the compue pipeline
        computePipeline = try ComputePipeline(device: device, computeFunction: "calcParticles", drawMesh: particleMesh, boxDimension: boxDimension)
        
        meshes.append(boxMesh)
        meshes.append(crosshairMesh)
        meshes.append(particleMesh)
        
    }
    
    func draw(in view: MTKView) {
        //gpuLock.wait()
        
        // compute delta time
        let currentTime = CACurrentMediaTime()
        let timeDifference = (lastRenderTime == nil) ? 0 : (currentTime - lastRenderTime!)
        
        frameTimeSum += timeDifference
        
        // Save this system time
        lastRenderTime = currentTime
        
        computePass(deltaTime: timeDifference)
        let computeTimeEnd = CACurrentMediaTime()
        computeTimeSum += computeTimeEnd - currentTime
        renderPass(view: view)
        
        
        
        frameCount += 1
        
        if(frameTimeSum >= 1) {
            statsObservable.frameTime = frameTimeSum / Double(frameCount)
            statsObservable.computeTime = computeTimeSum / Double(frameCount)
            frameCount = 0
            frameTimeSum = 0
            computeTimeSum = 0
        }
        
    }
    
    func renderPass(view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        if (sampleCount > 1) {
            renderPassDescriptor.colorAttachments[0].texture = view.multisampleColorTexture
            renderPassDescriptor.colorAttachments[0].resolveTexture = view.currentDrawable?.texture
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        for mesh in meshes {
            mesh.drawWithRenderCommandEncoder(encoder: renderEncoder)
            //mesh.updateModelMatrix()
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        
        /*
        commandBuffer.addCompletedHandler {
            _ in self.gpuLock.signal()
        }
        */
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func computePass(deltaTime: CFTimeInterval) {
        currentTime += deltaTime
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {return}
        
        
        computePipeline.computeWithCommandEncoder(encoder: computeEncoder, deltaTime: deltaTime)
        
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspectRatio:Float = Float(size.width)/Float(size.height);
        camera.aspectRatio = aspectRatio
        camera.updatePerspectiveMatrix()
    }
    
    func scrollWheel(with event: NSEvent) {
        var z: Float = camera.position.z + Float(event.deltaY) * 0.2
        z = Float.maximum(camera.zNear, Float.minimum(camera.zFar, z))
        camera.position.z = z
        camera.updateMatrices()
    }
    
    func keyDown(with event: NSEvent) {
        let movementSpeed: Float = 0.25
        let pos = crosshairMesh.position
        
        var x = pos.x
        var y = pos.y
        var z = pos.z
        
        switch(event.characters) {
        case "a":
            x -= movementSpeed
        case "d":
            x += movementSpeed
        case "w":
            z -= movementSpeed
        case "s":
            z += movementSpeed
        default:
            break
        }
        
        switch(event.specialKey) {
        case NSEvent.SpecialKey.pageUp:
            y += movementSpeed
        case NSEvent.SpecialKey.pageDown:
            y -= movementSpeed
        default:
            break
        }
        
        let half = boxDimension / 2 + 0.0001
        
        if(x < -half.x || x > half.x) {
            x = crosshairMesh.position.x
        }
        if(y < -half.y || y > half.y) {
            y = crosshairMesh.position.y
        }
        if(z < -half.z || z > half.z) {
            z = crosshairMesh.position.z
        }
        
        crosshairMesh.setPostion(position: [x, y, z])
        
        // TODO: compute pipeline handlings
        
    }
    
    func keyUp(with event: NSEvent) {
        // TODO: compute pipeline handlings
    }
    
    func mouseDragged(with event: NSEvent) {
        let newPos: simd_float2 = [Float(event.locationInWindow.x), Float(event.locationInWindow.y)]
        
        let offset = (newPos - currentMousePos) * 0.2
        camera.rotateEuler(euler: [0, offset.x, 0]);
        camera.rotateEuler(euler: [-offset.y, 0, 0]);
        
        currentMousePos = newPos
    }

    func mouseDown(with event: NSEvent) {
        currentMousePos = [Float(event.locationInWindow.x), Float(event.locationInWindow.y)]
    }
    
    func updateParticleRenderParams() {
        let bufferPtr = particleRenderParamBuffer.buffer.contents()
        bufferPtr.storeBytes(of: particleRenderParams, as: ParticleRenderParams.self)
    }
    
    func updateColor(color: CGColor) {
        particleRenderParams.color = [
            Float(color.components![0]),
            Float(color.components![1]),
            Float(color.components![2]),
            Float(color.components![3])
        ]
        updateParticleRenderParams()
    }
}
