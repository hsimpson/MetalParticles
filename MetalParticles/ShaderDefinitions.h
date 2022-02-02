//
//  ShaderDefinitions.h
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

struct Vertex {
    vector_float3 pos;
    vector_float4 color;
};

struct Camera {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
};


#endif /* ShaderDefinitions_h */
