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
        material.baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    }
    
    if (!is_null_texture(roughnessTexture)) {
        material.roughness = roughnessTexture.sample(textureSampler, in.uv).r;
    }
    
    if (!is_null_texture(aoTexture)) {
        material.ambientOcclusion = aoTexture.sample(textureSampler, in.uv).r;
    }
    
    if (!is_null_texture(metallicTexture)) {
        material.metallic = metallicTexture.sample(textureSampler, in.uv).r;
    }
    
    float3 normal;
    if (is_null_texture(normalTexture)) {
      normal = in.worldNormal;
    } else {
      normal = normalTexture.sample(
      textureSampler,
      in.uv).rgb;
      normal = normal * 2 - 1;
      normal = float3x3(
        in.worldTangent,
        in.worldBitangent,
        in.worldNormal) * normal;
    }
    normal = normalize(normal);
    
    float3 diffuseColor = computeDiffuse(lights, params, material, normal);

    float3 specularColor = computeSpecular(lights, params, material, normal);
    
    return float4(diffuseColor + specularColor, 1);
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
