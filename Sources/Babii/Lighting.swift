//
//  Lighting.swift
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

struct DirectionalLight {
    let direction: SIMD3<Float>
    let ambient: SIMD3<Float>
    let diffuse: SIMD3<Float>
    let specular: SIMD3<Float>
}

struct PointLight {
    let position: SIMD3<Float>
    let ambient: SIMD3<Float>
    let diffuse: SIMD3<Float>
    let specular: SIMD3<Float>
    
    let constant: Float
    let linear: Float
    let quadratic: Float
}
