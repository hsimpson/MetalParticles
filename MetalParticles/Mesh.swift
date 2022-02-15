//
//  Mesh.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 02.02.22.
//

import Metal

class Mesh: Entity {
    private let renderPipeline: RenderPipeline
    private let geometry: Geometry
    private let camera: Camera
    private let uniformBuffer: MTLBuffer
    
    init(renderPipeline: RenderPipeline, geometry: Geometry, camera: Camera, device: MTLDevice) {
        self.renderPipeline = renderPipeline
        self.geometry = geometry
        self.camera = camera
        uniformBuffer = device.makeBuffer(length: MemoryLayout<simd_float4x4>.stride, options: [])!
    }
    
    func drawWithRenderCommendEncoder(encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(self.renderPipeline.pipeLineState)
        encoder.setVertexBuffer(geometry.vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(camera.uniformBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        
        if(geometry is IndexedGeometry) {
            let indexedGeometry = geometry as! IndexedGeometry
            encoder.drawIndexedPrimitives(type: indexedGeometry.primitiveType, indexCount: indexedGeometry.indexCount, indexType: .uint16, indexBuffer: indexedGeometry.indexBuffer, indexBufferOffset: 0)
        } else {
            encoder.drawPrimitives(type: geometry.primitiveType, vertexStart: 0, vertexCount: geometry.vertexCount)
        }
    }
    
    func updateUniformBuffer() {
        let bufferPtr = uniformBuffer.contents()
        bufferPtr.storeBytes(of: modelMatrix, as: simd_float4x4.self)
    }
    
    override func updateModelMatrix() {
        super.updateModelMatrix()
        updateUniformBuffer()
    }
}
