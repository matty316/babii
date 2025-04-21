//
//  Shaders.metal
//  Babii
//
//  Created by matty on 2/12/25.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
  float3 normal [[attribute(1)]];
  float2 uv [[attribute(2)]];
};

struct Transformation {
    matrix_float4x4 model;
    matrix_float4x4 view;
    matrix_float4x4 projection;
};

struct Fragment {
    float4 position [[position]];
};

vertex Fragment
vertexShader(VertexIn in [[stage_in]],
             constant Transformation *transformation [[buffer(1)]]) {
    Fragment out;
        
    out.position = transformation->projection * transformation->view * transformation->model * in.position;
    
    return out;
}

fragment float4 fragmentShader(Fragment in [[stage_in]]) {
    return float4(1, 0, 0, 1);
}
