//
//  Cube.swift
//  babii
//
//  Created by Matthew Reed on 4/24/25.
//

import MetalKit

struct Cube: Model {
    let diffuse: MTLTexture
    let specular: MTLTexture
    let type: ModelType
    var position: SIMD3<Float> = [0, -0.75, 0]
    var rotationAngle: Float = 0
    var rotation: SIMD3<Float> = [0, 0, 0]
    var scale: Float = 0.5
  
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
        self.type = .Vertex
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, cameraPosition: SIMD3<Float>, lightCount: Int) {
        let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        
        renderEncoder.setFragmentTexture(diffuse, index: 0)
        renderEncoder.setFragmentTexture(specular, index: 1)
        var params = Params(hasSpecular: 1, lightCount: 0, cameraPosition: cameraPosition)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: 6)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
