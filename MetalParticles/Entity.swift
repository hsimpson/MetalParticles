//
//  Entity.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 03.02.22.
//

import Metal

class Entity {
    var position: simd_float3 = simd_float3.init([0, 0, 0])
    var rotation: simd_quatf = simd_quatf.init(vector: [0, 0, 0, 1])
    var scale: simd_float3 = simd_float3.init([1, 1, 1])
    let entityBuffer: MetalBuffer
    
    init(device: MTLDevice) {
        let buffer = device.makeBuffer(length: MemoryLayout<simd_float4x4>.stride, options: [])!
        entityBuffer = MetalBuffer(buffer: buffer, offset: 0, index: 2)
        updateModelMatrix()
    }
    
    func updateModelMatrix() {
        let translationMatrix = simd_float4x4.makeTranslationMatrix(translation: position)
        let rotationMatrix = simd_float4x4.init(rotation)
        let scaleMatrix = simd_float4x4.makeScaleMatrix(scale: scale)
        let modelMatrix = translationMatrix * rotationMatrix * scaleMatrix
        let bufferPtr = entityBuffer.buffer.contents()
        bufferPtr.storeBytes(of: modelMatrix, as: simd_float4x4.self)
        
    }
    
    func translate(translation: simd_float3) {
        position += translation
        updateModelMatrix()
    }
    
    func rotateQuat(rot: simd_quatf) {
        rotation = rot * rotation
        updateModelMatrix()
    }
    
    func rotateEuler(euler: simd_float3) {
        let quat = simd_quatf(euler: euler)
        rotateQuat(rot: quat)
    }
    
    func scale(scale: simd_float3) {
        self.scale *= scale
    }
    
    func setPostion(position: simd_float3) {
        self.position = position
        updateModelMatrix()
    }
}
