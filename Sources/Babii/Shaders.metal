//
//  Shaders.metal
//  Babii
//
//  Created by matty on 2/12/25.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct Vertex {
    float3 position;
    float4 color;
};

struct Fragment {
    float4 position [[position]];
    float4 color;
};

vertex Fragment
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(0)]],
             constant vector_uint2* viewportSizePointer [[buffer((1))]]) {
    Fragment out;
    vector_float2 viewport_size = vector_float2(*viewportSizePointer);
        
    out.position = float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = vertices[vertexID].position.xy / (viewport_size / 2.0);
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 fragmentShader(Fragment in [[stage_in]]) {
    
    
    return in.color;
}
