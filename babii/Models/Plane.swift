//
//  Plane.swift
//  babii
//
//  Created by Matthew Reed on 4/24/25.
//

import MetalKit

struct Plane: Model {
    let diffuse: MTLTexture
    let specular: MTLTexture
    let mesh: MTKMesh
    let type: ModelType
    var position: SIMD3<Float> = [0, -1, 0]
    var rotationAngle: Float = 270
    var rotation: SIMD3<Float> = [0, 0, 1]
    var scale: Float = 20
    
    init(diffuse: MTLTexture, specular: MTLTexture, device: MTLDevice) {
        self.type = .Ground
        self.diffuse = diffuse
        self.specular = specular
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh = MDLMesh(
            planeWithExtent: [1, 1, 1],
            segments: [4, 4],
            geometryType: .triangles,
            allocator: allocator
        )
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
    }
    
    func render(renderEncoder: any MTLRenderCommandEncoder, device: any MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int) {
        renderEncoder.setFragmentTexture(diffuse, index: 0)
        renderEncoder.setFragmentTexture(specular, index: 1)
        var params = Params(hasSpecular: 1, lightCount: 0, cameraPosition: cameraPosition)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: 6)
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
