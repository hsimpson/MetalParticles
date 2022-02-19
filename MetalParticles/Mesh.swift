//
//  Mesh.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 02.02.22.
//

import Metal

class Mesh: Entity {
    let renderPipeline: RenderPipeline
    let geometry: Geometry
    let camera: Camera
    var vertexBuffers: [MetalBuffer] = []
    var fragmentBuffers: [MetalBuffer] = []
    
    init(renderPipeline: RenderPipeline, geometry: Geometry, camera: Camera, device: MTLDevice) {
        self.renderPipeline = renderPipeline
        self.geometry = geometry
        self.camera = camera
        super.init(device: device)
    }
    
    func drawWithRenderCommandEncoder(encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(self.renderPipeline.pipeLineState)
        encoder.setVertexBuffer(camera.cameraBuffer.buffer, offset: camera.cameraBuffer.offset, index: camera.cameraBuffer.index)
        encoder.setVertexBuffer(entityBuffer.buffer, offset: entityBuffer.offset, index: entityBuffer.index)
        
        for vertexBuffer in vertexBuffers {
            encoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: vertexBuffer.index)
        }
        
        for fragmentBuffer in fragmentBuffers {
            encoder.setFragmentBuffer(fragmentBuffer.buffer, offset: fragmentBuffer.offset, index: fragmentBuffer.index)
        }
        
        
        if(geometry is IndexedGeometry) {
            let indexedGeometry = geometry as! IndexedGeometry
            encoder.drawIndexedPrimitives(type: indexedGeometry.primitiveType, indexCount: indexedGeometry.indexCount, indexType: .uint16, indexBuffer: indexedGeometry.indexBuffer, indexBufferOffset: 0)
        } else {
            encoder.drawPrimitives(type: geometry.primitiveType, vertexStart: 0, vertexCount: geometry.vertexCount)
        }
    }
}
