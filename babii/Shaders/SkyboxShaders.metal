//
//  SkyboxShaders.metal
//  babii
//
//  Created by Matthew Reed on 6/30/25.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn {
  float4 position [[attribute(0)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 textureCoordinates;
};

vertex VertexOut vertex_skybox(
  const VertexIn in [[stage_in]],
  constant Transformation &transformation [[buffer(11)]])
{
  VertexOut out;
  float4x4 vp = transformation.projection * transformation.view;
  out.position = (vp * in.position).xyww;
  out.textureCoordinates = in.position.xyz;
  return out;
}

fragment half4 fragment_skybox(
  VertexOut in [[stage_in]],
  texturecube<half> cubeTexture [[texture(0)]])
{
  constexpr sampler default_sampler(filter::linear);
  half4 color = cubeTexture.sample(
    default_sampler,
    in.textureCoordinates);
  return color;
}
