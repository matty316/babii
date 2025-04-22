//
//  Fragment.metal
//  Babii
//
//  Created by matty on 4/21/25.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
#import "ShaderDefs.h"

//float3 calcDirLight(DirectionalLight light, float3 normal, float3 viewDir);

fragment float4 fragmentShader(Fragment in [[stage_in]], texture2d<float> diffuse [[texture(0)]]) {
    float3 color;
    if (!is_null_texture(diffuse)) {
        constexpr sampler textureSampler (mag_filter::linear, min_filter::linear, address::repeat);
        color = diffuse.sample(textureSampler, in.uv).rgb;
    } else {
        color = float3(1, 0, 0);
    }
    return float4(color, 1);
}

//float3 calcDirLight(DirectionalLight light, float3 normal, float3 viewDir) {
//    float3 lightDir = normalize(-light.direction);
//    float diff = max(dot(normal, lightDir), 0.0);
//    float3 reflectDir = reflect(-lightDir, normal);
//    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess)
//}
