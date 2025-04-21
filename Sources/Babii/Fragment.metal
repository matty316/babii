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

fragment float4 fragmentShader(Fragment in [[stage_in]]) {
    return float4(1, 0, 0, 1);
}

//float3 calcDirLight(DirectionalLight light, float3 normal, float3 viewDir) {
//    float3 lightDir = normalize(-light.direction);
//    float diff = max(dot(normal, lightDir), 0.0);
//    float3 reflectDir = reflect(-lightDir, normal);
//    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess)
//}
