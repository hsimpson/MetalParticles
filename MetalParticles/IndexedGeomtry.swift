//
//  IndexedGeomtry.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

import Foundation
import Metal

class IndexedGeometry {
    
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let indexCount: Int
    
    init(vertices: [Vertex], indices: [UInt16], device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])!
        indexCount = indices.count
    }
}
