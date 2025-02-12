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
    float2 texCoords;
    float3 normal;
    bool top;
};

struct TransformationData {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 perspectiveMatrix;
};

struct RasterizerData {
    float4 position [[position]];
    float2 texCoords;
    bool top;
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(0)]],
             constant TransformationData* transformationData[[buffer((1))]]) {
    RasterizerData out;
        
    out.position = transformationData[vertexID].perspectiveMatrix * transformationData[vertexID].viewMatrix * transformationData[vertexID].modelMatrix * vertices[vertexID].position;
    out.texCoords = vertices[vertexID].texCoords;
    out.top = vertices[vertexID].top;
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]],
                               texture2d<float> sideTexture [[texture(0)]],
                               texture2d<float> topTexture [[texture(1)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    const float4 colorSample = in.top ? topTexture.sample(textureSampler, in.texCoords) : sideTexture.sample(textureSampler, in.texCoords);
    
    return colorSample;
}
