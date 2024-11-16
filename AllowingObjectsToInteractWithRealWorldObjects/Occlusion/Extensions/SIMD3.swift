/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension of SIMD3 to lock the y-axis value to 0.
*/

import SwiftUI

/// The extension of `SIMD3` where the scalar is a float.
extension SIMD3 where Scalar == Float {
    /// The computed variable to lock the y-axis value to 0.
    var grounded: SIMD3<Scalar> {
        return .init(x: x, y: 0, z: z)
    }
}
