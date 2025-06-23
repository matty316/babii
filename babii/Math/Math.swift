//
//  Math.swift
//  Babii
//
//  Created by matty on 2/13/25.
//

import simd

enum Math {
    static func perspective(fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let ys = 1 / tan(fovyRadians * 0.5)
        let xs = ys / aspect
        let zs = farZ / (nearZ - farZ)
        
        return matrix_float4x4(rows: [[xs, 0, 0, 0],
                                      [0, ys, 0, 0],
                                      [0, 0, zs, nearZ * zs],
                                      [0, 0, -1, 0]])
    }
    
    static func lookAt(position: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
        let zaxis = normalize(position - target)
        let xaxis = normalize(cross(normalize(up), zaxis))
        let yaxis = cross(zaxis, xaxis)
        
        let t: SIMD3<Float> = [-simd_dot(xaxis, position), -simd_dot(yaxis, position), -simd_dot(zaxis, position)]
        
        return matrix_float4x4(rows: [[xaxis.x, xaxis.y, xaxis.z, t.x],
                                      [yaxis.x, yaxis.y, yaxis.z, t.y],
                                      [zaxis.x, zaxis.y, zaxis.z, t.z],
                                      [0, 0, 0, 1]])
    }
    
    static func radians(from degrees: Float) -> Float {
        return degrees * .pi / 180
    }
    
    static func translation(vector: SIMD3<Float>) -> matrix_float4x4 {
        return matrix_float4x4(rows: [[1, 0, 0, vector.x],
                                      [0, 1, 0, vector.y],
                                      [0, 0, 1, vector.z],
                                      [0, 0, 0, 1]])
    }
    
    static func rotation(angle: Float, vector: SIMD3<Float>) -> matrix_float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        let d = 1 - c
        
        let x = vector.x * d
        let y = vector.y * d
        let z = vector.z * d
        
        let axay = x * vector.y
        let axaz = z * vector.z
        let ayaz = y * vector.z
        
        return matrix_float4x4(rows: [[c + x * vector.x, axay - s * vector.z, axaz + s * vector.y, 0],
                                      [axay + s * vector.z, c + y * vector.y, ayaz - s * vector.x, 0],
                                      [axaz - s * vector.y, ayaz + s * vector.x, c + z * vector.z, 0],
                                      [0, 0, 0, 1]])
    }
    
    static func scale(vector: SIMD3<Float>) -> matrix_float4x4 {
        return matrix_float4x4(rows: [[vector.x, 0, 0, 0],
                                      [0, vector.y, 0, 0],
                                      [0, 0, vector.z, 0],
                                      [0, 0, 0,        1]])
    }
}

extension float4x4 {
    var upperLeft: float3x3 {
        let x = columns.0.xyz
        let y = columns.1.xyz
        let z = columns.2.xyz
        return float3x3(columns: (x, y, z))
    }
}

extension SIMD4<Float> {
  var xyz: SIMD3<Float> {
    get {
        SIMD3<Float>(x, y, z)
    }
    set {
      x = newValue.x
      y = newValue.y
      z = newValue.z
    }
  }

  // convert from double4
  init(_ d: SIMD4<Double>) {
    self.init()
    self = [Float(d.x), Float(d.y), Float(d.z), Float(d.w)]
  }
}
