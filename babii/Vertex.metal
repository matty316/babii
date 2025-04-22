//
//  Vertex.metal
//  Babii
//
//  Created by matty on 4/21/25.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
#import "ShaderDefs.h"

vertex Fragment
vertexShader(VertexIn in [[stage_in]],
             constant Transformation *transformation [[buffer(1)]]) {
    Fragment out;
        
    out.position = transformation->projection * transformation->view * transformation->model * in.position;
    out.normal = in.normal;
    out.uv = in.uv;
    
    return out;
}
