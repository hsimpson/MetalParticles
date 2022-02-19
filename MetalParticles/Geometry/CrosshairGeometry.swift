//
//  Crosshair.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 03.02.22.
//

import Metal

class CrosshairGeometry: IndexedGeometry {
    
    init(dimension: simd_float3, device: MTLDevice) {
        let half = dimension * 0.5
        let red: simd_float4 = [1, 0, 0, 1]
        let green: simd_float4 = [0, 1, 0, 1]
        let blue: simd_float4 = [0, 0, 1, 1]
        
        let vertices: [GeometryVertex] = [
            // x axis
            GeometryVertex(pos: [-half.x, 0, 0], color: red),
            GeometryVertex(pos: [half.x, 0, 0], color: red),

            // y axis
            GeometryVertex(pos: [0, -half.y, 0], color: green),
            GeometryVertex(pos: [0, half.y, 0], color: green),

            // z axis
            GeometryVertex(pos: [0, 0, -half.z], color: blue),
            GeometryVertex(pos: [0, 0, half.z], color: blue),
        ]
        
        let indices: [UInt16] = [
            // x axis
            0, 1,

            // y axis
            2, 3,

            // z axis
            4, 5
        ]
        
        super.init(vertices: vertices, vertexStride: MemoryLayout<GeometryVertex>.stride, vertexCount: vertices.count, indices: indices, primitiveType: .line, device: device)
    }
}
