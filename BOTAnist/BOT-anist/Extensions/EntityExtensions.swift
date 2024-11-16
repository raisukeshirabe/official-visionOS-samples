/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Extensions on Entity and ModelEntity that add commonly used custom variables and functions.
*/

import RealityKit
import Foundation
import SwiftUI

public extension Entity {
    var jointPinComponent: JointPinComponent? {
        get { components[JointPinComponent.self] }
        set { components[JointPinComponent.self] = newValue }
    }

    #if os(visionOS)
    /// Generates a rotation animation for the entity from its current orientation to face the person playing.
    func getRotationAnimation(toFace: SquareAzimuth, duration: TimeInterval) -> AnimationResource? {
        let quat = simd_quatf(toFace.orientation)
        let fromTransform = transform
        let toTransform = Transform(scale: transform.scale, rotation: quat, translation: transform.translation)
        let rotateAnim = FromToByAnimation(name: "rotation", from: fromTransform, to: toTransform, duration: duration, bindTarget: .transform )
        return try? AnimationResource.generate(with: rotateAnim)
    }
    #endif
}

extension ModelEntity {
    func getJointIndex(suffix: String) -> Int? {
        return jointNames
            .enumerated()
            .first(where: { $0.element.hasSuffix(suffix) })?
            .offset
    }
}
