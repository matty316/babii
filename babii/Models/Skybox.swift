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
    
    let mesh: MTKMesh
    let skyTexture: MTLTexture?
    
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int) {
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        let submesh = mesh.submeshes[0]
        renderEncoder.setFragmentTexture(skyTexture, index: 0)
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
            let library = try device.makeDefaultLibrary(bundle: .main)
            
            let vertexFunction = library.makeFunction(name: "vertex_skybox")
            let fragmentFunction = library.makeFunction(name: "fragment_skybox")
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
