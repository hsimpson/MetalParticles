//
//  Crosshair.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 03.02.22.
//

class Crosshair {
    let vertices: [Vertex]
    let indices: [UInt16]
    
    init(dimension: vector_float3) {
        let half = dimension * 0.5
        let red: vector_float4 = [1, 0, 0, 1]
        let green: vector_float4 = [0, 1, 0, 1]
        let blue: vector_float4 = [0, 0, 1, 1]
        
        vertices = [
            // x axis
            Vertex(pos: [-half.x, 0, 0], color: red),
            Vertex(pos: [half.x, 0, 0], color: red),

            // y axis
            Vertex(pos: [0, -half.y, 0], color: green),
            Vertex(pos: [0, half.y, 0], color: green),

            // z axis
            Vertex(pos: [0, 0, -half.z], color: blue),
            Vertex(pos: [0, 0, half.z], color: blue),
        ]
        
        indices = [
            // x axis
            0, 1,

            // y axis
            2, 3,

            // z axis
            4, 5
        ]
    }
}
