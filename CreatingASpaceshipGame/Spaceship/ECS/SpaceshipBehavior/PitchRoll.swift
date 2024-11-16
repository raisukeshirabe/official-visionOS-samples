/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Component for storing pitch and roll.
*/

import RealityKit

struct PitchRollComponent: Component {
    var pitch: Float // radians
    var roll: Float  // radians

    init(pitch: Float = .zero, roll: Float = .zero) {
        self.pitch = pitch
        self.roll = roll
    }
}
