/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension of Float3, Float4, and Float4x4 that creates additional calculations.
*/

import RealityKit
import simd

/// The type alias to create a new name for SIMD3<Float>.
typealias Float3 = SIMD3<Float>

/// The type alias to create a new name for SIMD4<Float>.
typealias Float4 = SIMD4<Float>

/// The type alias to create a new name for simd_float4x4.
typealias Float4x4 = simd_float4x4

extension Float3 {
    // Initialize Float4 with Float3 inputs.
    init(_ float4: Float4) {
        self.init()
        
        x = float4.x
        y = float4.y
        z = float4.z
    }
}

extension Float4 {
    /// Ignore the W value to convert Float4 into Float3.
    func toFloat3() -> Float3 {
        Float3(self)
    }
}

extension Float4x4 {
    /// The value to access the identity of Float4x4.
    static var identity: Float4x4 {
        matrix_identity_float4x4
    }
    
    /// The translation component of Float4x4 and return as Float3.
    func translation() -> Float3 {
        columns.3.toFloat3()
    }
}

/// Create a mathematical clamp.
func clamp(_ valueX: Float, min minV: Float, max maxV: Float) -> Float {
    return min(maxV, max(minV, valueX))
}
