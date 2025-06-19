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
    int hasSpecular;
};

struct DirectionalLight {
    vector_float3 direction;
  
    vector_float3 ambient;
    vector_float3 diffuse;
    vector_float3 specular;
};

struct PointLight {
    vector_float3 position;
    vector_float3 attenuation;
    vector_float3 ambient;
    vector_float3 diffuse;
    vector_float3 specular;
};

#endif /* Common_h */
