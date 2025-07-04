//
//  Common.h
//  babii
//
//  Created by Matthew Reed on 4/22/25.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

struct Params {
    uint32_t lightCount;
    vector_float3 cameraPosition;
    uint8_t tiling;
};

struct Material {
    vector_float3 baseColor;
    float roughness;
    float metallic;
    float ambientOcclusion;
};

struct Transformation {
    matrix_float4x4 model;
    matrix_float4x4 view;
    matrix_float4x4 projection;
    matrix_float3x3 normal;
};

typedef enum {
    unused = 0,
    Sun = 1,
    Spot = 2,
    Point = 3,
    Ambient = 4
} LightType;

struct Light {
    LightType type;
    vector_float3 position;
    vector_float3 color;
};

#endif /* Common_h */
