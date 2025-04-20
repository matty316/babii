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
        
    }
}
