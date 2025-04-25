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
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice)
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
