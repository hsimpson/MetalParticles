//
//  Rendering.metal
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

#include <metal_stdlib>
#include "ShaderDefinitions.h"

using namespace metal;

struct VertexOut {
    float4 color;
    float4 pos [[position]];
};

struct ParticleOut {
    float4 pos [[position]];
    float pointSize [[point_size]];
};

vertex VertexOut objectVertex(const device GeometryVertex *vertexArray [[buffer(0)]],
                              constant Camera &camera [[buffer(1)]],
                              constant Model &model [[buffer(2)]],
                              unsigned int vid [[vertex_id]]) {
    // Get the data for the current vertex.
    GeometryVertex in = vertexArray[vid];
    
    VertexOut out;
    out.pos = camera.projectionMatrix * camera.viewMatrix * model.modelMatrix * float4(in.pos.xyz, 1.0);
    out.color = in.color;
        
    return out;
}

fragment float4 objectFragment(VertexOut interpolated [[stage_in]]) {
    return interpolated.color;
}

vertex ParticleOut particleVertex(const device ParticleVertex *vertexArray [[buffer(0)]],
                                constant Camera &camera [[buffer(1)]],
                                constant Model &model [[buffer(2)]],
                                unsigned int vid [[vertex_id]]) {
    
    ParticleVertex in = vertexArray[vid];
    ParticleOut out;
    out.pos = camera.projectionMatrix * camera.viewMatrix * model.modelMatrix * float4(in.pos.xyz, 1.0);
    out.pointSize = 1.0;
    
    return out;
}

fragment float4 particleFragment(ParticleOut interpolated [[stage_in]]) {
    return float4(1.0, 0.0, 0.0, 1.0);
}
