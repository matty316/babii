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
#import "Common.h"

constexpr sampler textureSampler (mag_filter::linear, min_filter::linear, address::repeat);
float3 calcDirLight(DirectionalLight light, float3 normal, float3 viewDir, Material material, float2 uv);
float3 calcPointLight(PointLight light, float3 normal, float3 fragPos, float3 viewDir, Material material, float2 uv);

fragment float4 fragmentShader(Fragment in [[stage_in]],
                               texture2d<float> diffuse [[texture(0)]],
                               texture2d<float> specular [[texture(1)]],
                               constant float3 &viewPos [[buffer(2)]],
                               constant DirectionalLight &dirLight [[buffer(3)]],
                               constant PointLight *pointLights [[buffer(4)]],
                               constant uint &numOfPointLights [[buffer(5)]],
                               constant Params &params [[buffer(6)]]) {
    float3 norm = normalize(in.normal);
    float3 fragPos = in.worldPosition.xyz;
    float3 viewDir = normalize(viewPos - fragPos);
    if (!is_null_texture(diffuse) && !is_null_texture(specular) && params.hasSpecular == 1) {
        Material material{diffuse, specular, 32.0f};
        float3 result = calcDirLight(dirLight, norm, viewDir, material, in.uv);
        
        for (size_t i = 0; i < numOfPointLights; i++)
            result += calcPointLight(pointLights[i], norm, fragPos, viewDir, material, in.uv);
        
        return float4(result, 1);
    } else if (!is_null_texture(diffuse)) {
        float3 color = diffuse.sample(textureSampler, in.uv).rgb;
        return float4(color, 1);
    }
    return float4(1, 0, 0, 1);
}

fragment float4 fragmentSolid(Fragment in [[stage_in]]) {
    return float4(1, 0, 0, 1);
}

float3 calcDirLight(DirectionalLight light, float3 normal, float3 viewDir, Material material, float2 uv) {
    float3 lightDir = normalize(-light.direction);
    float diff = saturate(dot(normal, lightDir));
    float3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(saturate(dot(viewDir, reflectDir)), material.shininess);
    float3 ambient = light.ambient * material.diffuse.sample(textureSampler, uv).rgb;
    float3 diffuse = light.diffuse * diff * material.diffuse.sample(textureSampler, uv).rgb;
    float3 specular = light.specular * spec * material.specular.sample(textureSampler, uv).rgb;
    return ambient + diffuse + specular;
}

float3 calcPointLight(PointLight light, float3 normal, float3 fragPos, float3 viewDir, Material material, float2 uv) {
    float3 lightDir = normalize(light.position - fragPos);
    float diff = saturate(dot(normal, lightDir));
    float3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(saturate(dot(viewDir, reflectDir)), material.shininess);
    float d = distance(light.position, fragPos);
    float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
    float3 ambient = light.ambient * material.diffuse.sample(textureSampler, uv).rgb;
    float3 diffuse = light.diffuse * diff * material.diffuse.sample(textureSampler, uv).rgb;
    float3 specular = light.specular * spec * material.specular.sample(textureSampler, uv).rgb;

    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    return ambient + diffuse + specular;
}
