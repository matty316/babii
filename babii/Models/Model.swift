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
    var rotation: SIMD3<Float> { get set }
    var scale: Float { get set }
    var modelMatrix: matrix_float4x4 { get }
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int)
}

extension Model {
    var modelMatrix: matrix_float4x4 {
        let translation = Math.translation(vector: position)
        let rotation = Math.rotate(rotation: rotation)
        let scale = Math.scale(vector: [scale, scale, scale])
        return translation * rotation * scale
    }
}

extension MTLVertexDescriptor {
    static func vertexDescriptor() -> MTLVertexDescriptor {
        return MTKMetalVertexDescriptorFromModelIO(.vertexDescriptor())!
    }
    
}

extension MDLVertexDescriptor {
    static func vertexDescriptor() -> MDLVertexDescriptor {
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
        
        vertexDescriptor.attributes[3] = MDLVertexAttribute(
            name: MDLVertexAttributeTangent,
            format: .float3,
            offset: 0,
            bufferIndex: 1
        )
        vertexDescriptor.layouts[1] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        
        vertexDescriptor.attributes[4] = MDLVertexAttribute(
            name: MDLVertexAttributeBitangent,
            format: .float3,
            offset: 0,
            bufferIndex: 2
        )
        vertexDescriptor.layouts[2] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)

        
        return vertexDescriptor
    }
}

struct Model3d: Model {
    var type: ModelType = .ModelIO
    var position: SIMD3<Float>
    var rotationAngle: Float
    var rotation: SIMD3<Float>
    var scale: Float
    var meshes: [Mesh] = []
        
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int) {
        var params = Params(lightCount: UInt32(lightCount), cameraPosition: cameraPosition, tiling: 1)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: 6)
        
        for mesh in meshes {
            for (i, vertexBuffer) in mesh.mtkMesh.vertexBuffers.enumerated() {
                renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: i)
            }
            for submesh in mesh.submeshes {
                renderEncoder.setFragmentTexture(submesh.baseColor, index: 0)
                renderEncoder.setFragmentTexture(submesh.roughness, index: 1)
                renderEncoder.setFragmentTexture(submesh.normal, index: 2)
                renderEncoder.setFragmentTexture(submesh.ambientOcclussion, index: 3)
                renderEncoder.setFragmentTexture(submesh.metallic, index: 4)
                var material = submesh.material
                renderEncoder.setFragmentBytes(&material, length: MemoryLayout<Material>.stride, index: 7)
                renderEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
                )
            }
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
        
        let asset = MDLAsset(url: assetUrl, vertexDescriptor: .vertexDescriptor(), bufferAllocator: allocator)
        asset.loadTextures()
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
        
        for mdlMesh in mdlMeshes {
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, tangentAttributeNamed: MDLVertexAttributeTangent, bitangentAttributeNamed: MDLVertexAttributeBitangent)
            let mtkMesh = try! MTKMesh(mesh: mdlMesh, device: device)
            self.meshes.append(Mesh(mtkMesh: mtkMesh, mdlMesh: mdlMesh, device: device))
        }
    }
}

struct Mesh {
    let mtkMesh: MTKMesh
    let mdlMesh: MDLMesh
    var submeshes = [Submesh]()
    
    init(mtkMesh: MTKMesh, mdlMesh: MDLMesh, device: MTLDevice) {
        self.mtkMesh = mtkMesh
        self.mdlMesh = mdlMesh
        submeshes = zip(mtkMesh.submeshes, mdlMesh.submeshes!).map { mesh in
            Submesh(mtkSubmesh: mesh.0, mdlSubmesh: mesh.1 as! MDLSubmesh, device: device)
        }
    }
}

struct Submesh {
    let indexCount: Int
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexBufferOffset: Int
    
    let material: Material
    let baseColor: MTLTexture?
    let roughness: MTLTexture?
    let normal: MTLTexture?
    let ambientOcclussion: MTLTexture?
    let metallic: MTLTexture?
    
    init(mtkSubmesh: MTKSubmesh, mdlSubmesh: MDLSubmesh, device: MTLDevice) {
        self.indexType = mtkSubmesh.indexType
        self.indexCount = mtkSubmesh.indexCount
        self.indexBuffer = mtkSubmesh.indexBuffer.buffer
        self.indexBufferOffset = mtkSubmesh.indexBuffer.offset
        self.material = Material(material: mdlSubmesh.material)
        self.baseColor = mdlSubmesh.material?.texture(type: .baseColor, device: device)
        self.roughness = mdlSubmesh.material?.texture(type: .roughness, device: device)
        self.normal = mdlSubmesh.material?.texture(type: .tangentSpaceNormal, device: device)
        self.ambientOcclussion = mdlSubmesh.material?.texture(type: .ambientOcclusion, device: device)
        self.metallic = mdlSubmesh.material?.texture(type: .metallic, device: device)
    }
}

private extension MDLMaterial {
    func texture(type semantic: MDLMaterialSemantic, device: MTLDevice) -> MTLTexture? {
        if let property = property(with: semantic),
           property.type == .texture,
           let mdlTexture = property.textureSamplerValue?.texture {
            return TextureLoader.shared.loadTexture(
                texture: mdlTexture,
                name: property.stringValue ?? UUID().uuidString,
                device: device)
        }
        return nil
  }
}

private extension Material {
    init(material: MDLMaterial?) {
        self.init()
        if let baseColor = material?.property(with: .baseColor),
          baseColor.type == .float3 {
          self.baseColor = baseColor.float3Value
        }
        if let roughness = material?.property(with: .roughness),
          roughness.type == .float {
          self.roughness = roughness.floatValue
        }
        if let metallic = material?.property(with: .metallic),
           metallic.type == .float {
          self.metallic = metallic.floatValue
        }
        self.ambientOcclusion = 1
    }
}


