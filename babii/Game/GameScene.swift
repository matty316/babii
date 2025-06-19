//
//  GameScene.swift
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

import CoreGraphics
import GameController
import MetalKit

struct GameScene {
    var cam = Camera()
    var controls = Controls()
    var models = [Model]()
    var lastMouseDelta = Controls.Point()
    var textureLoader = TextureLoader()
    let groundVertexDescriptor: MTLVertexDescriptor?
    
    init(device: MTLDevice) {
        if let diffuse = textureLoader.loadTexture(name: "container", device: device),
           let specular  = textureLoader.loadTexture(name: "container_spec", device: device) {
            let cube = Cube(diffuse: diffuse, specular: specular)
            models.append(cube)
        }
        if let diffuse = textureLoader.loadTexture(name: "ground", device: device),
           let specular = textureLoader.loadTexture(name: "ground_spec", device: device) {
            let ground = Plane(diffuse: diffuse, specular: specular, device: device)
            models.append(ground)
            self.groundVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(ground.mesh.vertexDescriptor)
        } else {
            self.groundVertexDescriptor = nil
        }
        
        if let diffuse = textureLoader.loadTexture(name: "mushroom", device: device) {
            let mushroom = Model3d(device: device, assetName: "mushroom", position: [0, 0, 0], rotationAngle: 0, rotation: [0, 0, 0], scale: 1, texture: diffuse)
            models.append(mushroom)
        }
    }
    
    mutating func update(size: CGSize) {
        cam.update(size: size)
    }
    
    mutating func update(deltaTime: Float) {
        if controls.keysPressed.contains(.keyW) {
            cam.processKeyboardMovement(direction: .forward, deltaTime: deltaTime)
        }
        if controls.keysPressed.contains(.keyS) {
            cam.processKeyboardMovement(direction: .backward, deltaTime: deltaTime)
        }
        if controls.keysPressed.contains(.keyA) {
            cam.processKeyboardMovement(direction: .left, deltaTime: deltaTime)
        }
        if controls.keysPressed.contains(.keyD) {
            cam.processKeyboardMovement(direction: .right, deltaTime: deltaTime)
        }
        
        let delta = lastMouseDelta
                
        if abs(controls.mouseDelta.x - delta.x) + abs(controls.mouseDelta.y - delta.y) > 0.0001 {
            cam.processMouseMovement(mouseDelta: controls.mouseDelta)
            lastMouseDelta = controls.mouseDelta
        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, groundPipelineState: MTLRenderPipelineState, vertexPipelineState: MTLRenderPipelineState, model3DPipelineState: MTLRenderPipelineState) {
        var viewPos = cam.position
        renderEncoder.setFragmentBytes(&viewPos, length: MemoryLayout<SIMD3<Float>>.stride, index: 2)
        
        let ambient: Float = 0.05
        var diffuse: Float = 0.4
        var specular: Float = 0.5
        var dirLight = DirectionalLight(
            direction: [-0.2, -1.0, -0.3],
            ambient: [ambient, ambient, ambient],
            diffuse: [diffuse, diffuse, diffuse],
            specular: [specular, specular, specular]
        )
        
        diffuse = 0.8
        specular = 1.0
        let pointLightPositions: [SIMD3<Float>] = [
            [0.7, 0.2, 2.0],
            [2.3, -3.3, -4.0],
            [-4.0, 2.0, -12.0],
            [0.0, 0.0, -3.0],
        ]
        
        var pointLights = [PointLight]()
        for position in pointLightPositions {
            let point = PointLight(
                position: position,
                attenuation: [1.0, 0.09, 0.032],
                ambient: [ambient, ambient, ambient],
                diffuse: [diffuse, diffuse, diffuse],
                specular: [specular, specular, specular]
            )
            pointLights.append(point)
        }
        
        renderEncoder.setFragmentBytes(&dirLight, length: MemoryLayout<DirectionalLight>.stride, index: 3)
        renderEncoder.setFragmentBytes(&pointLights, length: MemoryLayout<PointLight>.stride * pointLights.count, index: 4)
        var count = UInt32(pointLights.count)
        renderEncoder.setFragmentBytes(&count, length: MemoryLayout<UInt32>.stride, index: 5)
        for model in models {
            var transformation = cam.transformation(model: model.modelMatrix)
            renderEncoder.setVertexBytes(&transformation, length: MemoryLayout<Transformation>.stride, index: 11)
            switch model.type {
            case .ModelIO:
                renderEncoder.setRenderPipelineState(model3DPipelineState)
            case .Vertex:
                renderEncoder.setRenderPipelineState(vertexPipelineState)
            case .Ground:
                renderEncoder.setRenderPipelineState(groundPipelineState)
            }
            model.render(renderEncoder: renderEncoder, device: device)
        }
    }
}
