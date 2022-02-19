//
//  IndexedGeomtry.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

import Foundation
import Metal

class IndexedGeometry: Geometry {
    
    let indexBuffer: MTLBuffer
    let indexCount: Int
    
    init(vertices: UnsafeRawPointer, vertexStride: Int, vertexCount: Int, indices: [UInt16], primitiveType: MTLPrimitiveType, device: MTLDevice) {
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])!
        indexCount = indices.count
        super.init(vertices: vertices, vertexStride: vertexStride, vertexCount: vertexCount, primitiveType: primitiveType, device: device)
    }
}
