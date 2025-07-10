//
//  shadows.metal
//  babii
//
//  Created by matty on 7/9/25.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4
  vertex_depth(const VertexIn in [[stage_in]],
  constant Transformation &tranformation [[buffer(11)]])
{
  matrix_float4x4 mvp =
    tranformation.projection * tranformation.view
    * tranformation.model;
  return mvp * in.position;
}
