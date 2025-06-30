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

float3 computeSpecular(constant Light *lights, constant Params &params, Material material, float3 normal);
float3 computeDiffuse(constant Light *lights, constant Params &params, Material material, float3 normal);
float3 fresnelSchlick(float cosTheta, float3 F0);
float distributionGGX(float3 N, float3 H, float roughness);
float geometrySchlickGGX(float NdotV, float roughness);
float geometrySmith(float3 N, float3 V, float3 L, float roughness);

fragment float4 fragmentShader(Fragment in [[stage_in]],
                               texture2d<float> baseColorTexture [[texture(0)]],
                               texture2d<float> roughnessTexture [[texture(1)]],
                               texture2d<float> normalTexture [[texture(2)]],
                               texture2d<float> aoTexture [[texture(3)]],
                               texture2d<float> metallicTexture [[texture(4)]],
                               constant float3 &viewPos [[buffer(2)]],
                               constant Light *lights [[buffer(3)]],
                               constant Params &params [[buffer(6)]],
                               constant Material &_material [[buffer(7)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear, address::repeat);
    
    Material material = _material;
    
    if (!is_null_texture(baseColorTexture)) {
        material.baseColor = pow(baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb, 2.2);
    }
    
    if (!is_null_texture(roughnessTexture)) {
        material.roughness = roughnessTexture.sample(textureSampler, in.uv * params.tiling).r;
    }
    
    if (!is_null_texture(aoTexture)) {
        material.ambientOcclusion = aoTexture.sample(textureSampler, in.uv * params.tiling).r;
    }
    
    if (!is_null_texture(metallicTexture)) {
        material.metallic = metallicTexture.sample(textureSampler, in.uv * params.tiling).r;
    }
    
    float3 normal;
    if (is_null_texture(normalTexture)) {
      normal = in.worldNormal;
    } else {
      normal = normalTexture.sample(
      textureSampler,
      in.uv * params.tiling).rgb;
      normal = normal * 2 - 1;
      normal = float3x3(
        in.worldTangent,
        in.worldBitangent,
        in.worldNormal) * normal;
    }
    float3 N = normalize(normal);
    float3 V = normalize(params.cameraPosition - in.worldPosition.xyz);
    
    float3 F0 = float3(0.04);
    F0 = mix(F0, material.baseColor, material.metallic);
    
    float3 Lo = float3(0.0);
    for (size_t i = 0; i < params.lightCount; i++) {
        float3 L = normalize(lights[i].position - in.worldPosition.xyz);
        float3 H = normalize(V + L);
        float distance = length(lights[i].position - in.worldPosition.xyz);
        float attenuation = 1.0 / (distance * distance);
        float3 radiance = lights[i].color * attenuation;
        
        float NDF = distributionGGX(N, H, material.roughness);
        float G = geometrySmith(N, V, L, material.roughness);
        float3 F = fresnelSchlick(saturate(dot(H, V)), F0);
        
        float3 kS = F;
        float3 kD = float3(1.0) - kS;
        kD *= 1.0 - material.metallic;
        
        float3 numerator = NDF * G * F;
        float denominator = 4.0 * saturate(dot(N, V)) * saturate(dot(N, L)) + 0.0001;
        float3 specular = numerator / denominator;
        
        
        float NdotL = saturate(dot(N, L));
        Lo += (kD * material.baseColor / M_PI_F + specular) * radiance * NdotL;
    }
    
    float3 ambient = float3(0.03) * material.baseColor * material.ambientOcclusion;
    float3 color = ambient + Lo;
    
    color = color / (color + float3(1.0));
    color = pow(color, float3(1.0/2.2));
    
    return float4(color, 1.0);
}

fragment float4 fragmentSolid(Fragment in [[stage_in]]) {
    return float4(1, 0, 0, 1);
}

float G1V(float nDotV, float k)
{
  return 1.0f / (nDotV * (1.0f - k) + k);
}

// specular optimized-ggx
// AUTHOR John Hable. Released into the public domain
float3 computeSpecular(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal)
{
  float3 viewDirection = normalize(params.cameraPosition);
  float3 specularTotal = 0;
  for (uint i = 0; i < params.lightCount; i++) {
    Light light = lights[i];
    float3 lightDirection = normalize(light.position);
    float3 F0 = mix(0.04, material.baseColor, material.metallic);
    // add a small amount of bias so that you can
    // see the shininess when roughness is zero
    float bias = 0.01;
    float roughness = material.roughness + bias;
    float alpha = roughness * roughness;
    float3 halfVector = normalize(viewDirection + lightDirection);
    float nDotL = saturate(dot(normal, lightDirection));
    float nDotV = saturate(dot(normal, viewDirection));
    float nDotH = saturate(dot(normal, halfVector));
    float lDotH = saturate(dot(lightDirection, halfVector));

    float3 F;
    float D, vis;

    // Distribution
    float alphaSqr = alpha * alpha;
    float pi = 3.14159f;
    float denom = nDotH * nDotH * (alphaSqr - 1.0) + 1.0f;
    D = alphaSqr / (pi * denom * denom);

    // Fresnel
    float lDotH5 = pow(1.0 - lDotH, 5);
    F = F0 + (1.0 - F0) * lDotH5;

    // V
    float k = alpha / 2.0f;
    vis = G1V(nDotL, k) * G1V(nDotV, k);

    float3 specular = nDotL * D * F * vis;
    specularTotal += specular;
  }
  return specularTotal;
}

// diffuse
float3 computeDiffuse(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal)
{
  float3 diffuseTotal = 0;
  for (uint i = 0; i < params.lightCount; i++) {
    Light light = lights[i];
    float3 lightDirection = normalize(light.position);
    float nDotL = saturate(dot(normal, lightDirection));
    float3 diffuse = float3(material.baseColor) * (1.0 - material.metallic);
    diffuseTotal += diffuse * nDotL * material.ambientOcclusion;
  }
  return diffuseTotal;
}

float3 fresnelSchlick(float cosTheta, float3 F0) {
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float distributionGGX(float3 N, float3 H, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = saturate(dot(N, H));
    float NdotH2 = NdotH * NdotH;
    
    float num = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = M_PI_F * denom * denom;
    
    return num / denom;
}

float geometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;
    
    float num = NdotV;
    float denom = NdotV * (1.0 - k) + k;
    
    return num / denom;
}

float geometrySmith(float3 N, float3 V, float3 L, float roughness) {
    float NdotV = saturate(dot(N, V));
    float NdotL = saturate(dot(N, L));
    float ggx2 = geometrySchlickGGX(NdotV, roughness);
    float ggx1 = geometrySchlickGGX(NdotL, roughness);
    
    return ggx1 * ggx2;
}

