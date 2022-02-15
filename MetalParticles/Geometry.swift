//
//  Geometry.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 14.02.22.
//

import Metal

class Geometry {
    let primitiveType: MTLPrimitiveType
    let vertexBuffer: MTLBuffer
    let vertexCount: Int
    
    init (vertices: UnsafeRawPointer, vertexStride: Int, vertexCount: Int, primitiveType: MTLPrimitiveType, device: MTLDevice) {
        self.primitiveType = primitiveType
        self.vertexCount = vertexCount
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexStride * vertexCount, options: [])!
    }
}
