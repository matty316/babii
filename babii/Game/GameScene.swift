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
    var cam = Camera(cameraType: .fps)
    var controls = Controls()
    var models = [Model]()
    var lastMouseDelta = Controls.Point()
    var groundVertexDesc: MTLVertexDescriptor

    init(device: MTLDevice) {
        let pancakes = Model3d(device: device, assetName: "pancakes_photogrammetry", position: [0, -1, 0], rotationAngle: 0, rotation: [0, 0, 0], scale: 0.05)
        models.append(pancakes)
        let groundDiff = TextureLoader.shared.loadTexture(name: "wood", device: device)
        let groundRough = TextureLoader.shared.loadTexture(name: "wood_rough", device: device)
        let groundAo = TextureLoader.shared.loadTexture(name: "wood_ao", device: device)
        let groundNorm = TextureLoader.shared.loadTexture(name: "wood_norm", device: device)
        let ground = Plane(diffuse: groundDiff, roughness: groundRough, ao: groundAo, metallic: nil, normal: groundNorm, device: device)
        models.append(ground)
        self.groundVertexDesc = MTKMetalVertexDescriptorFromModelIO(ground.mesh.vertexDescriptor)!
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
    
    func render(renderEncoder: MTLRenderCommandEncoder, device: MTLDevice, pipelineState: MTLRenderPipelineState, groundPipelineState: MTLRenderPipelineState) {
        var viewPos = cam.position
        renderEncoder.setFragmentBytes(&viewPos, length: MemoryLayout<SIMD3<Float>>.stride, index: 2)
        
        var lights = SceneLighting().lights
        
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: 3)
        
        for model in models {
            var transformation = cam.transformation(model: model.modelMatrix)
            renderEncoder.setVertexBytes(&transformation, length: MemoryLayout<Transformation>.stride, index: 11)
            if model.type == .Ground {
                renderEncoder.setRenderPipelineState(groundPipelineState)
            } else {
                renderEncoder.setRenderPipelineState(pipelineState)
            }
            model.render(renderEncoder: renderEncoder, device: device, cameraPosition: cam.position, lightCount: lights.count)
        }
    }
}

struct SceneLighting {
  static func buildDefaultLight() -> Light {
    var light = Light()
    light.position = [0, 0, 0]
    light.color = SIMD3<Float>(repeating: 1.0)
    light.specularColor = SIMD3<Float>(repeating: 0.6)
    light.attenuation = [1, 0, 0]
    light.type = Sun
    return light
  }

  let sunlight: Light = {
    var light = Self.buildDefaultLight()
    light.position = [1.8, 2.2, -2.9]
    light.color = SIMD3<Float>(repeating: 1)
    return light
  }()

  let fillLight: Light = {
    var light = Self.buildDefaultLight()
    light.position = [-5, 1, 3]
    light.color = SIMD3<Float>(repeating: 0.6)
    return light
  }()

  var lights: [Light] = []

  init() {
    lights = [sunlight, fillLight]
  }
}
