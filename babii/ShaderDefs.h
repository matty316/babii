//
//  ShaderDefs.h
//  Babii
//
//  Created by matty on 4/21/25.
//

#ifndef ShaderDefs_h
#define ShaderDefs_h

struct VertexIn {
  float4 position [[attribute(0)]];
  float4 normal [[attribute(1)]];
  float2 uv [[attribute(2)]];
};

struct Transformation {
    matrix_float4x4 model;
    matrix_float4x4 view;
    matrix_float4x4 projection;
};

struct Fragment {
    float4 position [[position]];
    float4 normal;
    float2 uv;
};

struct Material {
    texture2d<float> diffuse;
    texture2d<float> specular;
    float shininess;
};

#endif
