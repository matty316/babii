//
//  Model.swift
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

import MetalKit

protocol Model {
    var mesh: MTKMesh { get }
    var vertexDescriptor: MTLVertexDescriptor? { get }
    func render(renderEncoder: MTLRenderCommandEncoder)
}

struct Cube: Model {
    let mesh: MTKMesh
    let vertexDescriptor: MTLVertexDescriptor?
    init(device: MTLDevice) {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        
        self.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
