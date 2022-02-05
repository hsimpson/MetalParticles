//
//  Camera.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

import Metal

class Camera {
    var perspectiveMatrix: simd_float4x4 = matrix_identity_float4x4
    var viewMatrix: simd_float4x4 = matrix_identity_float4x4
    var rotation: simd_quatf = simd_quatf.init(vector: [0, 0, 0, 1])
    var position: simd_float3 = simd_float3.init()
    var target: simd_float3 = simd_float3.init()
    var up: simd_float3 = simd_float3.init([0, 1, 0])
    var fovY: Float = 45.0
    var aspectRatio: Float = 1.0
    var zNear: Float = 0.1
    var zFar: Float = 1000
    let uniformBuffer: MTLBuffer
    
    init(fovY: Float, aspectRatio: Float, zNear: Float, zFar: Float, device: MTLDevice) {
        self.fovY = fovY
        self.aspectRatio = aspectRatio
        self.zNear = zNear
        self.zFar = zFar
        
        uniformBuffer = device.makeBuffer(length: 2 * MemoryLayout<simd_float4x4>.stride, options: [])!
    }
    
    func updateMatrices(){
        updateViewMatrix()
        updatePerspectiveMatrix()
    }
    
    func updateViewMatrix() {
        let rotationMatrix = simd_float4x4.init(rotation)
        let translationMatrix = simd_float4x4.lookAt(eye: position, center: target, up: up)
        viewMatrix = translationMatrix * rotationMatrix
        updateUniformBuffer()
    }
    
    func updatePerspectiveMatrix() {
        perspectiveMatrix = simd_float4x4.perspetive(fovY: deg2Rad(degrees: fovY), aspectRatio: aspectRatio, zNear: zNear, zFar: zFar)
        updateUniformBuffer()
    }
    
    func updateUniformBuffer() {
        let bufferPtr = uniformBuffer.contents()
        let size = MemoryLayout<simd_float4x4>.stride
        bufferPtr.storeBytes(of: viewMatrix, as: simd_float4x4.self)
        bufferPtr.storeBytes(of: perspectiveMatrix, toByteOffset: size, as: simd_float4x4.self)
    }
    
    func rotateQuat(rot: simd_quatf) {
        rotation = rot * rotation
        updateViewMatrix()
    }
    
    func rotateEuler(euler: simd_float3) {
        let quat = simd_quatf(euler: euler)
        rotateQuat(rot: quat)
    }
}
