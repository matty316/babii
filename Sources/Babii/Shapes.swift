//
//  Shapes.swift
//  Babii
//
//  Created by matty on 2/13/25.
//

public enum Vertices {
    public static let triangle = [
        Vertex(pos: [ 0.5, -0.5, 0, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, -0.5, 0, 1.0], color: [0, 1, 0, 1]),
        Vertex(pos: [   0,  0.5, 0, 1.0], color: [0, 0, 1, 1]),
    ]
    
    public static let cube = [
        Vertex(pos: [-0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        //Back face
        Vertex(pos: [0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        //Top face
        Vertex(pos: [-0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        //Bottom face
        Vertex(pos: [-0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        //Left face
        Vertex(pos: [-0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [-0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        //Right face
        Vertex(pos: [0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, -0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, -0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, 0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
        Vertex(pos: [0.5, -0.5, 0.5, 1.0], color: [1, 0, 0, 1]),
    ]
}
