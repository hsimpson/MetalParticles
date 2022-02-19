//
//  ParticleGeometry.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 14.02.22.
//

import Metal

func createRandomParticles(count: UInt32, dimension: simd_float3) -> [ParticleVertex] {
    var v: [ParticleVertex] = []
    for _ in 0..<count {
        v.append(ParticleVertex(pos: [
            Float.random(in: 0.0..<1.0) * dimension.x - dimension.x / 2.0,
            Float.random(in: 0.0..<1.0) * dimension.y - dimension.y / 2.0,
            Float.random(in: 0.0..<1.0) * dimension.z - dimension.z / 2.0,
        ]))
    }
    return v
}

class ParticleGeometry: Geometry {
    init(particleCount: UInt32, boxDimension: simd_float3, device: MTLDevice) {
        let vertices: [ParticleVertex] = createRandomParticles(count: particleCount, dimension: boxDimension)
        
        super.init(vertices: vertices, vertexStride: MemoryLayout<ParticleVertex>.stride, vertexCount: vertices.count, primitiveType: .point, device: device)
    }
}
