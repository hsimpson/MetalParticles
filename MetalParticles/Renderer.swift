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
    var meshes: [Mesh] = []
    let camera: Camera
    
    init?(mtkView: MTKView) {
        device = mtkView.device!
        
        if (sampleCount > 1) {
            mtkView.sampleCount = sampleCount
        }
        
        commandQueue = device.makeCommandQueue()!
        
        let boxPipeline: RenderPipeline
        do {
            boxPipeline = try RenderPipeline(device: device, metalKitView: mtkView, sampleCount: sampleCount, vertexFunction: "objectVertex", fragmentFunction: "objectFragment")
        } catch {
            print("Unable to compile render pipeline state: \(error)")
            return nil
        }
        
        camera = Camera(fovY: 45.0, aspectRatio: Float(mtkView.bounds.width / mtkView.bounds.height), zNear: 0.1, zFar: 1000, device: device)
        camera.position = [0, 0, 15]
        camera.updateMatrices()
        
        let boxDimension: vector_float3 = [8, 5, 5]
        let box = Box(dimension: boxDimension)
        let boxGeometry = IndexedGeometry(vertices: box.vertices, indices: box.indices, device: device)
        meshes.append(Mesh(renderPipeline: boxPipeline, geometry: boxGeometry, camera: camera))
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
    }
}
