//
//  ComputePipeline.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 16.02.22.
//

import Metal
import MetalKit

func createVelocityArray(count: Int) -> [simd_float3] {
    let arr: [simd_float3] = [simd_float3](repeating: simd_float3.init(), count: count)
    return arr
}

class ComputePipeline {
    let device: MTLDevice
    let pipelineState: MTLComputePipelineState
    let drawMesh: Mesh
       
    let positionBuffer: MetalBuffer
    let velocityBuffer: MetalBuffer
    let computeUniformBuffer: MTLBuffer
    
    var computeParams: ComputeParams
    
    init(device: MTLDevice, computeFunction: String, drawMesh: Mesh, boxDimension: simd_float3) throws {
        self.device = device
        self.drawMesh = drawMesh
        positionBuffer = drawMesh.geometry.vertexBuffer
        
        let library = device.makeDefaultLibrary()
        let computeFunc = library!.makeFunction(name: computeFunction)
        
        pipelineState = try device.makeComputePipelineState(function: computeFunc!)
        let velocityArray = createVelocityArray(count: drawMesh.geometry.vertexCount)
        let velBuffer = device.makeBuffer(bytes: velocityArray, length: drawMesh.geometry.vertexCount * MemoryLayout<ParticleVertex>.stride, options: [])!
        
        velocityBuffer = MetalBuffer(buffer: velBuffer, offset: 0, index: 1)
        
        computeParams = ComputeParams(
            halfBounding: boxDimension/2,
            forcePosition: [0, 0, 0],
            deltaTime: 0.0001,
            gravity: 9.81, // 9.81 m/s² default earth gravity,
            force: 20,
            forceOn: 1)
        
        computeUniformBuffer = device.makeBuffer(bytes: UnsafeRawPointer(&computeParams), length: MemoryLayout<ComputeParams>.stride, options: [])!
    }
    
    func computeWithCommandEncoder(encoder: MTLComputeCommandEncoder, deltaTime: CFTimeInterval) {
        
        computeParams.deltaTime = Float(deltaTime)
        updateUniformBuffer()
        encoder.setComputePipelineState(pipelineState)
        
        // set buffer...
        encoder.setBuffer(computeUniformBuffer, offset: 0, index: 2)
        encoder.setBuffer(positionBuffer.buffer, offset: positionBuffer.offset, index: positionBuffer.index)
        encoder.setBuffer(velocityBuffer.buffer, offset: velocityBuffer.offset, index: velocityBuffer.index)
        
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        
        
        //let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadsPerThreadgroup = MTLSizeMake(pipelineState.maxTotalThreadsPerThreadgroup, 1, 1)
        let threadGroupsPerGrid = MTLSizeMake (drawMesh.geometry.vertexCount, 1, 1)
        //encoder.dispatchThreadgroups(threadGroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.dispatchThreads(threadGroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    func updateUniformBuffer() {
        let bufferPtr = computeUniformBuffer.contents()
        bufferPtr.storeBytes(of: computeParams, as: ComputeParams.self)
    }
    
    func updateParticles (count: UInt32) {
        
    }
    
    
    
    
}
