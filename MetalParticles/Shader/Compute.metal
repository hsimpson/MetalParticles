//
//  Compute.metal
//  MetalParticles
//
//  Created by Daniel Toplak on 16.02.22.
//

#include <metal_stdlib>
#include "ShaderDefinitions.h"

using namespace metal;

constant float3 EPSILON = float3(0.0001);

kernel void calcParticles(device float3 *positions [[buffer(0)]],
                          device float3 *velocities [[buffer(1)]],
                          constant ComputeParams &computeParams [[buffer(2)]],
                          uint id [[ thread_position_in_grid ]]) {
    
    float3 position = positions[id];
    float3 velocity = velocities[id];
    
    // Update particle position
    position += velocity * computeParams.deltaTime;
    
    // subtract gravity
    velocity.y -= computeParams.gravity * computeParams.deltaTime;
    
    float3 bbHalf = computeParams.halfBounding - EPSILON;
    
    if(position.x < -bbHalf.x) { // left
        position.x = -2.0 * bbHalf.x - position.x;
        velocity.x *= -0.9;
    } else if(position.x > bbHalf.x) { // right
        position.x = 2.0 * bbHalf.x - position.x;
        velocity.x *= -0.9;
    }
    
    if(position.y < -bbHalf.y) { // bottom
        position.y = -2.0 * bbHalf.y - position.y;
        if(computeParams.gravity > 0.0) {
            velocity.y *= -0.45; // damping
        }
        velocity.y *= -0.9;
    } else if(position.y > bbHalf.y) { // top
        position.y = 2.0 * bbHalf.y - position.y;
        if(computeParams.gravity > 0.0) {
            velocity.y *= 0.45; // damping
        }
        velocity.y *= -0.9;
    }
    
    if(position.z < -bbHalf.z) { // front
        position.z = -2.0 * bbHalf.z - position.z;
        velocity.z *= -0.9;
    } else if(position.z > bbHalf.z) { // back
        position.z = 2.0 * bbHalf.z - position.z;
        velocity.z *= -0.9;
    }
    
    if(computeParams.forceOn != 0) {
        float3 d = computeParams.forcePosition - position;
        float dist = sqrt(d.x * d.x + d.y * d.y + d.z * d.z);
        if(dist < 1.0) {
            dist = 1.0; // This line prevents anything that is really close from
                        // getting a huge force
        }
        
        velocity += d / dist * (computeParams.force * computeParams.deltaTime);
    }
    
    
    positions[id] = position;
    velocities[id] = velocity;
}
