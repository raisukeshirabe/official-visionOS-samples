/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Model data shared by all phases of the app.
*/

import SwiftUI
import RealityKit

@Observable
final class AppModel {

    var gamePhase: GamePhase = .joyRide

    var isPresentingAudioMixer = false
    var isPresentingHangar = false
    var isPresentingFlightSchool = false
    var isPresentingImmersiveSpace = false
    var wantsToPresentImmersiveSpace = false

    var isTransitioningBetweenSurroundings = false
    var isTransitioningBetweenGamePhases = false

    var shipControlParameters = ShipControlParameters()

    var audioMixer = AudioMixerStorage()

#if os(visionOS)
    var surroundings: Surroundings = .passthrough
    var immersionStyle: ImmersionStyle = .mixed

    func updateImmersion() {
        immersionStyle = surroundings.immersionStyle
    }
#endif
}

enum GamePhase: String, CaseIterable {

    case joyRide
    case work

    var displayName: String {
        switch self {
        case .joyRide: "Joy Ride"
        case .work: "Work"
        }
    }
}
