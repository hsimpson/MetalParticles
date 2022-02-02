//
//  simd_quatf-extensions.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 25.01.22.
//

import Foundation
import simd

public enum EulerOrder {
    case XYZ
    case XZY
    case YXZ
    case YZX
    case ZXY
    case ZYX
}

let EPSILON: Float = 0.000001

extension simd_quatf {
    public init(euler: simd_float3, order: EulerOrder = .ZYX) {
        self.init()
        
        let halfToRad = Float.pi / 360
        let half = euler * halfToRad
        
        let sx = sin(half.x)
        let cx = cos(half.x)
        let sy = sin(half.y)
        let cy = cos(half.y)
        let sz = sin(half.z)
        let cz = cos(half.z)
        
        // custom code
        switch order {
        case .XYZ:
            self.vector.x = sx * cy * cz + cx * sy * sz
            self.vector.y = cx * sy * cz - sx * cy * sz
            self.vector.z = cx * cy * sz + sx * sy * cz
            self.vector.w = cx * cy * cz - sx * sy * sz
        case .XZY:
            self.vector.x = sx * cy * cz - cx * sy * sz
            self.vector.y = cx * sy * cz - sx * cy * sz
            self.vector.z = cx * cy * sz + sx * sy * cz
            self.vector.w = cx * cy * cz + sx * sy * sz
        case .YXZ:
            self.vector.x = sx * cy * cz + cx * sy * sz
            self.vector.y = cx * sy * cz - sx * cy * sz
            self.vector.z = cx * cy * sz - sx * sy * cz
            self.vector.w = cx * cy * cz + sx * sy * sz
        case .YZX:
            self.vector.x = sx * cy * cz + cx * sy * sz
            self.vector.y = cx * sy * cz + sx * cy * sz
            self.vector.z = cx * cy * sz - sx * sy * cz
            self.vector.w = cx * cy * cz - sx * sy * sz
        case .ZXY:
            self.vector.x = sx * cy * cz - cx * sy * sz
            self.vector.y = cx * sy * cz + sx * cy * sz
            self.vector.z = cx * cy * sz + sx * sy * cz
            self.vector.w = cx * cy * cz - sx * sy * sz
        case .ZYX:
            self.vector.x = sx * cy * cz - cx * sy * sz
            self.vector.y = cx * sy * cz + sx * cy * sz
            self.vector.z = cx * cy * sz - sx * sy * cz
            self.vector.w = cx * cy * cz + sx * sy * sz
        }
    }
}

extension simd_float4x4 {
    public static func perspetive(fovY: Float, aspectRatio: Float, zNear: Float, zFar: Float) -> simd_float4x4 {
        let yScale = 1.0 / tan(fovY * 0.5)
        let xScale = yScale / aspectRatio
        let zRange = zFar - zNear
        let zScale = -(zFar + zNear) / zRange
        let wzScale = -2 * zFar * zNear / zRange
        
        
        let mat = simd_float4x4.init(columns: (
            [xScale, 0, 0, 0],
            [0, yScale, 0, 0],
            [0, 0, zScale, -1],
            [0, 0, wzScale, 0]
        ))
        
        return mat
    }
    
    public static func lookAt(eye: simd_float3, center: simd_float3, up: simd_float3) -> simd_float4x4 {
        let eyex = eye.x
        let eyey = eye.y
        let eyez = eye.z
        let upx = up.x
        let upy = up.y
        let upz = up.z
        let centerx = center.x
        let centery = center.y
        let centerz = center.z
        
        if (
            abs(eyex - centerx) < EPSILON &&
            abs(eyey - centery) < EPSILON &&
            abs(eyez - centerz) < EPSILON
        ) {
            return matrix_identity_float4x4
        }
        
        var z0 = eyex - centerx;
        var z1 = eyey - centery;
        var z2 = eyez - centerz;
        
        var len = 1 / simd_length(simd_float3([z0, z1, z2]))
        z0 *= len;
        z1 *= len;
        z2 *= len;
        
        var x0 = upy * z2 - upz * z1
        var x1 = upz * z0 - upx * z2
        var x2 = upx * z1 - upy * z0
        
        len = simd_length(simd_float3([x0, x1, x2]))
        if(len == 0) {
            x0 = 0
            x1 = 0
            x2 = 0
        } else {
            len = 1 / len
            x0 *= len
            x1 *= len
            x2 *= len
        }
        
        var y0 = z1 * x2 - z2 * x1
        var y1 = z2 * x0 - z0 * x2
        var y2 = z0 * x1 - z1 * x0
        
        len = simd_length(simd_float3([y0, y1, y2]))
        if(len == 0) {
            y0 = 0
            y1 = 0
            y2 = 0
        } else {
            len = 1 / len
            y0 *= len
            y1 *= len
            y2 *= len
        }
        
        let mat = simd_float4x4.init(columns: (
            [x0, y0, z0, 0],
            [x1, y1, z1, 0],
            [x2, y2, z2, 0],
            [-(x0 * eyex + x1 * eyey + x2 * eyez),
              -(y0 * eyex + y1 * eyey + y2 * eyez),
              -(z0 * eyex + z1 * eyey + z2 * eyez),
              1]
        ))
        
        return mat
        
    }
}

func deg2Rad(degrees: Float) -> Float {
    return degrees * Float.pi / 180
}

func rad2Deg(rad: Float) -> Float {
    return rad * 180 / Float.pi
}
