//
//  Vertex.swift
//  Babii
//
//  Created by Matthew Reed on 4/22/25.
//

import MetalKit

struct Vertex {
    let position: SIMD4<Float>
    let normal: SIMD3<Float>
    let uv: SIMD2<Float>
    
    init(_ position: SIMD4<Float>, _ normal: SIMD3<Float>, _ uv: SIMD2<Float>) {
        self.position = position
        self.normal = normal
        self.uv = uv
    }
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        descriptor.attributes[0].format = .float4
        descriptor.attributes[0].offset = 0
        descriptor.attributes[0].bufferIndex = 0
        
        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].offset = MemoryLayout<Vertex>.offset(of: \.normal)!
        descriptor.attributes[1].bufferIndex = 0
        
        descriptor.attributes[2].format = .float2
        descriptor.attributes[2].offset = MemoryLayout<Vertex>.offset(of: \.uv)!
        descriptor.attributes[2].bufferIndex = 0
        
        descriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        return descriptor
    }
}
