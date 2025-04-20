//
//  Camera.swift
//  Babii
//
//  Created by matty on 2/13/25.
//

import Foundation
import simd

public enum CameraDirection {
    case forward, backward, left, right
}

public enum CameraType {
    case fly, fps
}

public struct Camera {
    var position: SIMD3<Float> = [0, 0, 3]
    var front: SIMD3<Float> = [0, 0, -1]
    let worldUp: SIMD3<Float> = [0, 1, 0]
    var up: SIMD3<Float> = [0, 1, 0]
    var right: SIMD3<Float> = [-1, 0, 0]
    let cameraType: CameraType
    
    var yaw: Float = -90
    var pitch: Float = 0
    
    let movementSpeed: Float = 2.5
    let mouseSensitivity: Float = 0.1
    let zoom: Float = 45
    let fov = radians(from: 45)
    var aspect: Float = 1.0
    
    var view: matrix_float4x4 {
        lookAt(position: position, target: position + front, up: up)
    }
    
    var projection: matrix_float4x4 {
        perspective(fovyRadians: fov, aspect: aspect, nearZ: 0.1, farZ: 100)
    }
    
    var model: matrix_float4x4 {
        let translation = translation(vector: [0, 0, 0])
        let rotation = rotation(angle: radians(from: 45), vector: [0, 1, 0])
        return simd_mul(translation, rotation)
    }
    
    init(cameraType: CameraType = .fly) {
        self.cameraType = cameraType
        updateCameraVectors()
    }
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    mutating func updateCameraVectors() {
        var newFront: SIMD3<Float> = [0, 0, 0]
        newFront.x = cos(radians(from: yaw)) * cos(radians(from: pitch))
        newFront.y = sin(radians(from: pitch))
        newFront.z = sin(radians(from: yaw)) * cos(radians(from: pitch))
        front = normalize(newFront)
        right = normalize(cross(front, worldUp))
        up = normalize(cross(right, front))
    }
    
    public mutating func processKeyboardMovement(direction: CameraDirection, deltaTime: Float) {
        let velocity = movementSpeed * deltaTime
        
        switch direction {
        case .forward: position += front * velocity
        case .backward: position -= front * velocity
        case .left: position -= right * velocity
        case .right: position += right * velocity
        }
        
        if cameraType == .fps {
            position.y = 0
        }
    }
    
    mutating func processMouseMovement(mouseDelta: Controls.Point, constrainPitch: Bool = true) {
        var xOffset = mouseDelta.x
        var yOffset = mouseDelta.y
        
        xOffset *= mouseSensitivity
        yOffset *= mouseSensitivity
        
        yaw += xOffset
        pitch += yOffset
        
        if constrainPitch {
            if pitch > 89 {
                pitch = 89
            }
            if pitch < -89 {
                pitch = -89
            }
        }
        
        updateCameraVectors()
    }
}
