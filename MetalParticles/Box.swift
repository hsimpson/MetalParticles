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

import simd

class Box {
    let vertices: [Vertex]
    let indices: [UInt16]
    
    init(dimension: vector_float3) {
        let half = dimension * 0.5
        let color: vector_float4 = [1, 1, 1, 1]
        
        vertices = [
            // front vertices:
            Vertex(pos: [half.x, -half.y, -half.z], color: color),
            Vertex(pos: [half.x, half.y, -half.z], color: color),
            Vertex(pos: [-half.x, half.y, -half.z], color: color),
            Vertex(pos: [-half.x, -half.y, -half.z], color: color),
            
            // back vertices:
            Vertex(pos: [-half.x, -half.y, half.z], color: color),
            Vertex(pos: [-half.x, half.y, half.z], color: color),
            Vertex(pos: [half.x, half.y, half.z], color: color),
            Vertex(pos: [half.x, -half.y, half.z], color: color)
        ]
        
        indices = [
            // front
            0, 1, 1, 2, 2, 3, 3, 0,

            // left
            3, 2, 2, 5, 5, 4, 4, 3,

            // right
            7, 6, 6, 1, 1, 0, 0, 7,

            // back
            4, 5, 5, 6, 6, 7, 7, 4
        ]
    }
}
