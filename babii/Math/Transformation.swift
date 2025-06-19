//
//  Transformation.swift
//  Babii
//
//  Created by matty on 2/13/25.
//

import simd

struct Transformation {
    var model: matrix_float4x4 = matrix_float4x4()
    var view: matrix_float4x4 = matrix_float4x4()
    var projection: matrix_float4x4 = matrix_float4x4()
}
