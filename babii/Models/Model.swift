//
//  Model.swit
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

import MetalKit

enum ModelType {
    case ModelIO, Vertex
}

protocol Model {
    var type: ModelType { get }
    var position: SIMD3<Float> { get set }
    var rotationAngle: Float { get set }
    var rotation: SIMD3<Float> { get set }
    var scale: Float { get set }
    var modelMatrix: matrix_float4x4 { get }
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice)
}

extension Model {
    var modelMatrix: matrix_float4x4 {
        let translation = Math.translation(vector: position)
        let rotation = Math.rotation(angle: Math.radians(from: rotationAngle), vector: rotation)
        let scale = Math.scale(vector: [scale, scale, scale])
        return translation * rotation * scale
    }
}

extension MTLVertexDescriptor {
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        vertexDescriptor.attributes[0] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: 0)
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        vertexDescriptor.attributes[1] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: 0)
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        vertexDescriptor.attributes[2] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: offset,
            bufferIndex: 0)
        offset += MemoryLayout<SIMD2<Float>>.stride
        
        vertexDescriptor.layouts[0]
        = MDLVertexBufferLayout(stride: offset)
        
        return MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)!
    }
}
