//
//  Plane.swift
//  babii
//
//  Created by Matthew Reed on 4/24/25.
//

import MetalKit

struct Plane: Model {
    let diffuse: MTLTexture?
    let roughness: MTLTexture?
    let ao: MTLTexture?
    let metallic: MTLTexture?
    let normal: MTLTexture?
    let mesh: MTKMesh
    let type: ModelType
    var position: SIMD3<Float> = [0, -1, 0]
    var rotation: SIMD3<Float> = [0, 0, Math.radians(from: 270)]
    var scale: Float = 20
    var material: Material
    
    init(
        diffuse: MTLTexture?,
        roughness: MTLTexture?,
        ao: MTLTexture?,
        metallic: MTLTexture?,
        normal: MTLTexture?,
        device: MTLDevice
    ) {
        self.type = .Ground
        self.diffuse = diffuse
        self.roughness = roughness
        self.ao = ao
        self.metallic = metallic
        self.normal = normal
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh = MDLMesh(
            planeWithExtent: [1, 1, 1],
            segments: [4, 4],
            geometryType: .triangles,
            allocator: allocator
        )
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, tangentAttributeNamed: MDLVertexAttributeTangent, bitangentAttributeNamed: MDLVertexAttributeBitangent)
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        self.material = Material()
    }
    
    func render(renderEncoder: any MTLRenderCommandEncoder, device: any MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int) {
        renderEncoder.setFragmentTexture(diffuse, index: 0)
        renderEncoder.setFragmentTexture(roughness, index: 1)
        renderEncoder.setFragmentTexture(normal, index: 2)
        renderEncoder.setFragmentTexture(ao, index: 3)
        renderEncoder.setFragmentTexture(metallic, index: 4)
        var params = Params(lightCount: UInt32(lightCount), cameraPosition: cameraPosition, tiling: 16)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: 6)
        var material = self.material
        renderEncoder.setFragmentBytes(&material, length: MemoryLayout<Material>.stride, index: 7)
        for (i, buffer) in mesh.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(buffer.buffer, offset: 0, index: i)
        }
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
}
