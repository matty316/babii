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
    
    static func rotate(rotation: SIMD3<Float>) -> matrix_float4x4 {
        let c = cos(rotation * 0.5);
        let s = sin(rotation * 0.5);
        
        var quat = simd_float4(repeating: 1.0);

        quat.w = c.x * c.y * c.z + s.x * s.y * s.z;
        quat.x = s.x * c.y * c.z - c.x * s.y * s.z;
        quat.y = c.x * s.y * c.z + s.x * c.y * s.z;
        quat.z = c.x * c.y * s.z - s.x * s.y * c.z;
        
        var rotationMat = matrix_identity_float4x4;
        let qxx = quat.x * quat.x;
        let qyy = quat.y * quat.y;
        let qzz = quat.z * quat.z;
        let qxz = quat.x * quat.z;
        let qxy = quat.x * quat.y;
        let qyz = quat.y * quat.z;
        let qwx = quat.w * quat.x;
        let qwy = quat.w * quat.y;
        let qwz = quat.w * quat.z;

        rotationMat[0][0] = 1.0 - 2.0 * (qyy + qzz);
        rotationMat[0][1] = 2.0 * (qxy + qwz);
        rotationMat[0][2] = 2.0 * (qxz - qwy);

        rotationMat[1][0] = 2.0 * (qxy - qwz);
        rotationMat[1][1] = 1.0 - 2.0 * (qxx + qzz);
        rotationMat[1][2] = 2.0 * (qyz + qwx);

        rotationMat[2][0] = 2.0 * (qxz + qwy);
        rotationMat[2][1] = 2.0 * (qyz - qwx);
        rotationMat[2][2] = 1.0 - 2.0 * (qxx + qyy);
        
        return rotationMat
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
