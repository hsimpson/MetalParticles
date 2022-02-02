//
//  Pipeline.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 02.02.22.
//

import Metal
import MetalKit

class RenderPipeline {
    let pipeLineState: MTLRenderPipelineState
    
    init(device: MTLDevice, metalKitView: MTKView, sampleCount: Int, vertexFunction: String, fragmentFunction: String) throws {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: vertexFunction)
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: fragmentFunction)
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        if (sampleCount > 1) {
            pipelineDescriptor.rasterSampleCount = sampleCount
        }
        
        pipeLineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
