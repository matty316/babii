//
//  Model.swit
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

import MetalKit

enum ModelType {
    case ModelIO, Vertex, Ground
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
        return MTKMetalVertexDescriptorFromModelIO(Self.mdlVertexDescriptor())!
    }
    static func mdlVertexDescriptor() -> MDLVertexDescriptor {
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
        
        return vertexDescriptor
    }
}

struct Model3d: Model {
    var type: ModelType = .ModelIO
    
    var position: SIMD3<Float>
    
    var rotationAngle: Float
    
    var rotation: SIMD3<Float>
    
    var scale: Float
    
    let mesh: MTKMesh
    
    let texture: MTLTexture
    
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice) {
        renderEncoder.setFragmentTexture(texture, index: 0)
        var params = Params(hasSpecular: 0)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: 6)
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset
            )
        }
    }
    
    init(device: MTLDevice, assetName: String, position: SIMD3<Float>, rotationAngle: Float, rotation: SIMD3<Float>, scale: Float, texture: MTLTexture) {
        self.position = position
        self.rotationAngle = rotationAngle
        self.rotation = rotation
        self.scale = scale
        
        let allocator = MTKMeshBufferAllocator(device: device)
        
        guard let assetUrl = Bundle.main.url(forResource: assetName, withExtension: "usdz") else {
            fatalError("asset not in main bundle")
        }
        
        let asset = MDLAsset(url: assetUrl, vertexDescriptor: MTLVertexDescriptor.mdlVertexDescriptor(), bufferAllocator: allocator)
        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        self.texture = texture
    }
}
