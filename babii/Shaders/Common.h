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
    uint8_t hasSpecular;
    uint32_t lightCount;
    vector_float3 cameraPosition;
};

struct Material {
    vector_float3 baseColor;
    float roughness;
    float metallic;
    float ambientOcclusion;
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
    vector_float3 specularColor;
    float radius;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
};

#endif /* Common_h */
