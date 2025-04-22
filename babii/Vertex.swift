//
//  Vertex.swift
//  Babii
//
//  Created by Matthew Reed on 4/22/25.
//

struct Vertex {
    let position: SIMD3<Float>
    let normal: SIMD3<Float>
    let uv: SIMD2<Float>
    
    init(_ position: SIMD3<Float>, _ normal: SIMD3<Float>, _ uv: SIMD2<Float>) {
        self.position = position
        self.normal = normal
        self.uv = uv
    }
}
