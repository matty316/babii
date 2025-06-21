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
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int)
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
    let mesh: Mesh
        
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int) {
        var params = Params(hasSpecular: 0, lightCount: UInt32(lightCount), cameraPosition: cameraPosition)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: 6)
        renderEncoder.setVertexBuffer(mesh.mtkMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer,
                indexBufferOffset: submesh.indexBufferOffset
            )
        }
    }
    
    init(device: MTLDevice, assetName: String, position: SIMD3<Float>, rotationAngle: Float, rotation: SIMD3<Float>, scale: Float) {
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
        let mtkMesh = try! MTKMesh(mesh: mdlMesh, device: device)
        self.mesh = Mesh(mtkMesh: mtkMesh, mdlMesh: mdlMesh)
    }
}

struct Mesh {
    let mtkMesh: MTKMesh
    let mdlMesh: MDLMesh
    var submeshes = [Submesh]()
    
    init(mtkMesh: MTKMesh, mdlMesh: MDLMesh) {
        self.mtkMesh = mtkMesh
        self.mdlMesh = mdlMesh
        submeshes = zip(mtkMesh.submeshes, mdlMesh.submeshes!).map { mesh in
            Submesh(mtkMesh: mesh.0, mdlMesh: mesh.1 as! MDLSubmesh)
        }
    }
}

struct Submesh {
    let indexCount: Int
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexBufferOffset: Int
    
    let baseColor: MTLTexture?
    
    init(mtkSubmesh: MTKSubmesh, mdlSubmesh: MDLSubmesh) {
        self.indexType = mtkSubmesh.indexType
        self.indexCount = mtkSubmesh.indexCount
        self.indexBuffer = mtkSubmesh.indexBuffer.buffer
        self.indexBufferOffset = mtkSubmesh.indexBuffer.offset
        let material = mdlSubmesh.material!
        self.baseColor = material.texture(type: .baseColor)
    }
}

private extension MDLMaterial {
  func texture(type semantic: MDLMaterialSemantic) -> MTLTexture? {
    if let property = property(with: semantic),
       property.type == .texture,
       let mdlTexture = property.textureSamplerValue?.texture {
      return TextureController.loadTexture(
        texture: mdlTexture,
        name: property.textureName)
    }
    return nil
  }
}


