//
//  ShaderDefs.h
//  Babii
//
//  Created by matty on 4/21/25.
//

#ifndef ShaderDefs_h
#define ShaderDefs_h

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
    float3 tangent [[attribute(3)]];
    float3 bitangent [[attribute(4)]];
};

struct Fragment {
    float4 position [[position]];
    float3 normal;
    float2 uv;
    float4 worldPosition;
    float3 worldNormal;
    float3 worldTangent;
    float3 worldBitangent;
};

#endif
