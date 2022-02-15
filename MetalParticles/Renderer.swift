//
//  Renderer.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

import Metal
import MetalKit

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
    var particleCount: UInt32 = 100000
    
    init?(mtkView: MTKView) {
        device = mtkView.device!
        
        if (sampleCount > 1) {
            mtkView.sampleCount = sampleCount
        }
        
        commandQueue = device.makeCommandQueue()!
        
        let objectRenderPipeline: RenderPipeline
        let particleRenderPipeline: RenderPipeline
        do {
            objectRenderPipeline = try RenderPipeline(device: device, metalKitView: mtkView, sampleCount: sampleCount, vertexFunction: "objectVertex", fragmentFunction: "objectFragment")
            particleRenderPipeline = try RenderPipeline(device: device, metalKitView: mtkView, sampleCount: sampleCount, vertexFunction: "particleVertex", fragmentFunction: "particleFragment")
        } catch {
            print("Unable to compile render pipeline state: \(error)")
            return nil
        }
        
        camera = Camera(fovY: 45.0, aspectRatio: Float(mtkView.bounds.width / mtkView.bounds.height), zNear: 0.1, zFar: 1000, device: device)
        camera.position = [0, 0, 15]
        camera.updateMatrices()
        
        boxDimension = [8, 5, 5]
        let boxGeometry = BoxGeometry(dimension: boxDimension, device: device)
        boxMesh = Mesh(renderPipeline: objectRenderPipeline, geometry: boxGeometry, camera: camera, device: device)
        
        
        let crosshairGeometry = CrosshairGeometry(dimension: [1, 1, 1], device: device)
        crosshairMesh = Mesh(renderPipeline: objectRenderPipeline, geometry: crosshairGeometry, camera: camera, device: device)
        
        let particleGeometry = ParticleGeometry(particleCount: particleCount, boxDimension: boxDimension, device: device)
        let particleMesh = Mesh(renderPipeline: particleRenderPipeline, geometry: particleGeometry, camera: camera, device: device)
        
        meshes.append(boxMesh)
        meshes.append(crosshairMesh)
        meshes.append(particleMesh)
    }
    
    func draw(in view: MTKView) {
        gpuLock.wait()
        
        // compute delta time
        let systemTime = CACurrentMediaTime()
        let timeDifference = (lastRenderTime == nil) ? 0 : (systemTime - lastRenderTime!)
        
        update(deltaTime: timeDifference)
        
        // Save this system time
        lastRenderTime = systemTime
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        if (sampleCount > 1) {
            renderPassDescriptor.colorAttachments[0].texture = view.multisampleColorTexture
            renderPassDescriptor.colorAttachments[0].resolveTexture = view.currentDrawable?.texture
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        for mesh in meshes {
            mesh.drawWithRenderCommendEncoder(encoder: renderEncoder)
            //mesh.updateModelMatrix()
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        
        commandBuffer.addCompletedHandler {
            _ in self.gpuLock.signal()
        }
        
        commandBuffer.commit()
    }
    
    func update(deltaTime: CFTimeInterval) {
        currentTime += deltaTime
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
}
