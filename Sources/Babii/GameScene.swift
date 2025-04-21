//
//  GameScene.swift
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

import CoreGraphics
import MetalKit

struct GameScene {
    var cam = Camera()
    var controls = Controls()
    var models = [Model]()
    var lastDelta = Controls.Point()
    
    init(device: MTLDevice) {
        let cube = Cube(device: device)
        models.append(cube)
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
        
        let delta = lastDelta
                
        if abs(controls.mouseDelta.x - delta.x) + abs(controls.mouseDelta.y - delta.y) > 0.0001 {
            cam.processMouseMovement(mouseDelta: controls.mouseDelta)
            lastDelta = controls.mouseDelta
        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        var transformation = Transformation()
        transformation.view = cam.view
        transformation.projection = cam.projection
        transformation.model = cam.model
        renderEncoder.setVertexBytes(&transformation, length: MemoryLayout<Transformation>.stride, index: 1)
        for model in models {
            model.render(renderEncoder: renderEncoder)
        }
    }
}
