//
//  ShaderDefinitions.h
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

struct GeometryVertex {
    simd_float3 pos;
    simd_float4 color;
};

struct ParticleVertex {
    simd_float3 pos;
};


struct Camera {
    simd_float4x4 viewMatrix;
    simd_float4x4 projectionMatrix;
};

struct Model {
    simd_float4x4 modelMatrix;
};


#endif /* ShaderDefinitions_h */
