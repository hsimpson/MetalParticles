//
//  Mesh.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 02.02.22.
//

import Metal

class Mesh {
    private let renderPipeline: RenderPipeline
    private let geometry: IndexedGeometry
    private let camera: Camera
    
    init(renderPipeline: RenderPipeline, geometry: IndexedGeometry, camera: Camera) {
        self.renderPipeline = renderPipeline
        self.geometry = geometry
        self.camera = camera
    }
    
    func drawWithRenderCommendEncoder(encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(self.renderPipeline.pipeLineState)
        encoder.setVertexBuffer(geometry.vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(camera.uniformBuffer, offset: 0, index: 1)
        
        encoder.drawIndexedPrimitives(type: .line, indexCount: geometry.indexCount, indexType: .uint16, indexBuffer: geometry.indexBuffer, indexBufferOffset: 0)
    }
}
