//
//  Box.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

/* the cube:

     v5-----------v6
    / |          / |
   /  |         /  |
  v2----------v1   |
  |   |        |   |
  |   |        |   |
  |  v4--------|--v7
  | /          |  /
  |/           | /
  v3-----------v0

*/

import Metal

class BoxGeometry: IndexedGeometry {
    
    init(dimension: simd_float3, device: MTLDevice) {
        let half = dimension * 0.5
        let color: simd_float4 = [1, 1, 1, 1]
        
        let vertices: [GeometryVertex] = [
            // front vertices:
            GeometryVertex(pos: [half.x, -half.y, -half.z], color: color),
            GeometryVertex(pos: [half.x, half.y, -half.z], color: color),
            GeometryVertex(pos: [-half.x, half.y, -half.z], color: color),
            GeometryVertex(pos: [-half.x, -half.y, -half.z], color: color),
            
            // back vertices:
            GeometryVertex(pos: [-half.x, -half.y, half.z], color: color),
            GeometryVertex(pos: [-half.x, half.y, half.z], color: color),
            GeometryVertex(pos: [half.x, half.y, half.z], color: color),
            GeometryVertex(pos: [half.x, -half.y, half.z], color: color)
        ]
        
        let indices: [UInt16] = [
            // front
            0, 1, 1, 2, 2, 3, 3, 0,

            // left
            3, 2, 2, 5, 5, 4, 4, 3,

            // right
            7, 6, 6, 1, 1, 0, 0, 7,

            // back
            4, 5, 5, 6, 6, 7, 7, 4
        ]
        
        super.init(vertices: vertices, vertexStride: MemoryLayout<GeometryVertex>.stride, vertexCount: vertices.count, indices: indices, primitiveType: .line, device: device)
    }
}
