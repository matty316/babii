//
//  Plane.swift
//  babii
//
//  Created by Matthew Reed on 4/24/25.
//

import MetalKit

struct Plane: Model {
    let texture: MTLTexture
    let mesh: MTKMesh
    let type: ModelType
    
    init(texture: MTLTexture, device: MTLDevice) {
        self.type = .ModelIO
        self.texture = texture
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh = MDLMesh(
            planeWithExtent: [1, 1, 1],
            segments: [4, 4],
            geometryType: .triangles,
            allocator: allocator
        )
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
    }
    
    func render(renderEncoder: any MTLRenderCommandEncoder, device: any MTLDevice) {
        renderEncoder.setFragmentTexture(texture, index: 0)
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
