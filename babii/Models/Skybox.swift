//
//  Skybox.swift
//  babii
//
//  Created by Matthew Reed on 6/30/25.
//

import MetalKit

struct Skybox: Model {
    var type: ModelType = .Skybox
    
    var position: SIMD3<Float> = [0, 0, 0]
    
    var rotation: SIMD3<Float> = [0, 0, 0]
    
    var scale: Float = 1
    
    let pipelineState: MTLRenderPipelineState
    let shadowPipelineState: MTLRenderPipelineState
    
    let mesh: MTKMesh
    let skyTexture: MTLTexture?
    
    func render(
        renderEncoder: MTLRenderCommandEncoder,
        device: MTLDevice,
        cameraPosition: SIMD3<Float>,
        lightCount: Int,
        renderPassType: RenderPassType
    ) {
        switch renderPassType {
        case .Render:
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setFragmentTexture(skyTexture, index: 0)
        case .Shadow:
            renderEncoder.setRenderPipelineState(shadowPipelineState)
        }
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        let submesh = mesh.submeshes[0]
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
    }
    
    init(device: MTLDevice, imageName: String) {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh =  MDLMesh(
            boxWithExtent: [1, 1, 1],
            segments: [1, 1, 1],
            inwardNormals: true,
            geometryType: .triangles,
            allocator: allocator
        )
        
        self.skyTexture = TextureLoader.shared.loadCubeTexture(imageName: imageName, device: device)
        
        do {
            self.mesh = try MTKMesh(mesh: mdlMesh, device: device)
            
            guard let vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor) else {
                fatalError("Cannot create vertex descriptor")
            }
            self.pipelineState = try Self.createPipelineState(device: device, vertexDescriptor: vertexDescriptor, vertexName: "vertex_skybox", fragmentName: "fragment_skybox")
            self.shadowPipelineState = try Self.createShadowPipelineState(device: device, vertexDescriptor: vertexDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
