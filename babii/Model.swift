//
//  Model.swit
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

import MetalKit

protocol Model {
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice)
}

struct Cube: Model {
    let diffuse: MTLTexture
    let specular: MTLTexture
  
    let vertices: [Vertex] = [
        // Front Face
        Vertex([-0.5, -0.5,  0.5, 1.0], [ 0.0,  0.0,  1.0], [0.0, 0.0]),
        Vertex([ 0.5, -0.5,  0.5, 1.0], [ 0.0,  0.0,  1.0], [1.0, 0.0]),
        Vertex([ 0.5,  0.5,  0.5, 1.0], [ 0.0,  0.0,  1.0], [1.0, 1.0]),
        Vertex([ 0.5,  0.5,  0.5, 1.0], [ 0.0,  0.0,  1.0], [1.0, 1.0]),
        Vertex([-0.5,  0.5,  0.5, 1.0], [ 0.0,  0.0,  1.0], [0.0, 1.0]),
        Vertex([-0.5, -0.5,  0.5, 1.0], [ 0.0,  0.0,  1.0], [0.0, 0.0]),
        // Back Face
        Vertex([ 0.5, -0.5, -0.5, 1.0], [ 0.0,  0.0, -1.0], [0.0, 0.0]),
        Vertex([-0.5, -0.5, -0.5, 1.0], [ 0.0,  0.0, -1.0], [1.0, 0.0]),
        Vertex([-0.5,  0.5, -0.5, 1.0], [ 0.0,  0.0, -1.0], [1.0, 1.0]),
        Vertex([-0.5,  0.5, -0.5, 1.0], [ 0.0,  0.0, -1.0], [1.0, 1.0]),
        Vertex([ 0.5,  0.5, -0.5, 1.0], [ 0.0,  0.0, -1.0], [0.0, 1.0]),
        Vertex([ 0.5, -0.5, -0.5, 1.0], [ 0.0,  0.0, -1.0], [0.0, 0.0]),
        // Left Face
        Vertex([-0.5, -0.5, -0.5, 1.0], [-1.0,  0.0,  0.0], [0.0, 0.0]),
        Vertex([-0.5, -0.5,  0.5, 1.0], [-1.0,  0.0,  0.0], [1.0, 0.0]),
        Vertex([-0.5,  0.5,  0.5, 1.0], [-1.0,  0.0,  0.0], [1.0, 1.0]),
        Vertex([-0.5,  0.5,  0.5, 1.0], [-1.0,  0.0,  0.0], [1.0, 1.0]),
        Vertex([-0.5,  0.5, -0.5, 1.0], [-1.0,  0.0,  0.0], [0.0, 1.0]),
        Vertex([-0.5, -0.5, -0.5, 1.0], [-1.0,  0.0,  0.0], [0.0, 0.0]),
        // Right Face
        Vertex([ 0.5, -0.5,  0.5, 1.0], [ 1.0,  0.0,  0.0], [0.0, 0.0]),
        Vertex([ 0.5, -0.5, -0.5, 1.0], [ 1.0,  0.0,  0.0], [1.0, 0.0]),
        Vertex([ 0.5,  0.5, -0.5, 1.0], [ 1.0,  0.0,  0.0], [1.0, 1.0]),
        Vertex([ 0.5,  0.5, -0.5, 1.0], [ 1.0,  0.0,  0.0], [1.0, 1.0]),
        Vertex([ 0.5,  0.5,  0.5, 1.0], [ 1.0,  0.0,  0.0], [0.0, 1.0]),
        Vertex([ 0.5, -0.5,  0.5, 1.0], [ 1.0,  0.0,  0.0], [0.0, 0.0]),
        // Bottom Face
        Vertex([-0.5, -0.5, -0.5, 1.0], [ 0.0, -1.0,  0.0], [0.0, 0.0]),
        Vertex([ 0.5, -0.5, -0.5, 1.0], [ 0.0, -1.0,  0.0], [1.0, 0.0]),
        Vertex([ 0.5, -0.5,  0.5, 1.0], [ 0.0, -1.0,  0.0], [1.0, 1.0]),
        Vertex([ 0.5, -0.5,  0.5, 1.0], [ 0.0, -1.0,  0.0], [1.0, 1.0]),
        Vertex([-0.5, -0.5,  0.5, 1.0], [ 0.0, -1.0,  0.0], [0.0, 1.0]),
        Vertex([-0.5, -0.5, -0.5, 1.0], [ 0.0, -1.0,  0.0], [0.0, 0.0]),
        // Top Face
        Vertex([-0.5,  0.5,  0.5, 1.0], [ 0.0,  1.0,  0.0], [0.0, 0.0]),
        Vertex([ 0.5,  0.5,  0.5, 1.0], [ 0.0,  1.0,  0.0], [1.0, 0.0]),
        Vertex([ 0.5,  0.5, -0.5, 1.0], [ 0.0,  1.0,  0.0], [1.0, 1.0]),
        Vertex([ 0.5,  0.5, -0.5, 1.0], [ 0.0,  1.0,  0.0], [1.0, 1.0]),
        Vertex([-0.5,  0.5, -0.5, 1.0], [ 0.0,  1.0,  0.0], [0.0, 1.0]),
        Vertex([-0.5,  0.5,  0.5, 1.0], [ 0.0,  1.0,  0.0], [0.0, 0.0])
    ]
    
    init(diffuse: MTLTexture, specular: MTLTexture) {
        self.diffuse = diffuse
        self.specular = specular
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice) {
        let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        
        renderEncoder.setFragmentTexture(diffuse, index: 0)
        renderEncoder.setFragmentTexture(specular, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
