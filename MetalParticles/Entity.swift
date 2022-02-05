//
//  Entity.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 03.02.22.
//

class Entity {
    var modelMatrix: simd_float4x4 = matrix_identity_float4x4
    var position: simd_float3 = simd_float3.init([0, 0, 0])
    var rotation: simd_quatf = simd_quatf.init(vector: [0, 0, 0, 1])
    var scale: simd_float3 = simd_float3.init([1, 1, 1])
    
    init() {
        updateModelMatrix()
    }
    
    func updateModelMatrix() {
        let translationMatrix = simd_float4x4.makeTranslationMatrix(translation: position)
        let rotationMatrix = simd_float4x4.init(rotation)
        let scaleMatrix = simd_float4x4.makeScaleMatrix(scale: scale)
        modelMatrix = translationMatrix * rotationMatrix * scaleMatrix
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
