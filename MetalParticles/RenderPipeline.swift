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
        
        let colorAttachment0 = pipelineDescriptor.colorAttachments[0]!
        
        colorAttachment0.pixelFormat = metalKitView.colorPixelFormat
        colorAttachment0.isBlendingEnabled = true
        colorAttachment0.rgbBlendOperation = .add
        colorAttachment0.alphaBlendOperation = .add
        colorAttachment0.sourceRGBBlendFactor = .sourceAlpha
        colorAttachment0.sourceAlphaBlendFactor = .sourceAlpha
        
        if (sampleCount > 1) {
            pipelineDescriptor.rasterSampleCount = sampleCount
        }
        
        pipeLineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
