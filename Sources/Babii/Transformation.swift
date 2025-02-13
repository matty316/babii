//
//  Transformation.swift
//  Babii
//
//  Created by matty on 2/13/25.
//

import simd

struct Transformation {
    let model: matrix_float4x4
    let view: matrix_float4x4
    let projection: matrix_float4x4
}
