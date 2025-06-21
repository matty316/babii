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
    
    init(device: MTLDevice) {
        let pancakes = Model3d(device: device, assetName: "my-sphere", position: [0,0,0], rotationAngle: 0, rotation: [0,0,0], scale: 1)
        models.append(pancakes)
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
            model.render(renderEncoder: renderEncoder, device: device, cameraPosition: cam.position, lightCount: 0)
        }
    }
}
