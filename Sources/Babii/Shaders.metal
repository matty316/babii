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
    float4 position;
    float4 color;
};

struct Transformation {
    matrix_float4x4 model;
    matrix_float4x4 view;
    matrix_float4x4 projection;
};

struct Fragment {
    float4 position [[position]];
    float4 color;
};

vertex Fragment
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(0)]],
             constant Transformation *transformation [[buffer(1)]]) {
    Fragment out;
        
    out.position = transformation->projection * transformation->view * transformation->model * vertices[vertexID].position;
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 fragmentShader(Fragment in [[stage_in]]) {
    return in.color;
}
