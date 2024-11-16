/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
View model for the HangarView.
*/

import SwiftUI
import RealityKit
import CoreAudio
import AVFAudio

@MainActor @Observable
final class HangarViewModel {

    @ObservationIgnored
    var spaceship: Entity?
    let spaceshipAudio = SpaceshipAudioStorage()

    var throttle: Double = .zero

    func prepareSpaceship() async throws -> Entity {
        let spaceship = try await Entity.makeSpaceship()

        // Configure spaceship so that its audio and visuals respond to the throttle,
        // but doesn't fly away!
        spaceship.components.set(ThrottleComponent(throttle: .zero))
        spaceship.components.set(ShipAudioComponent())
        spaceship.components.set(ShipVisualsComponent())

        try await spaceshipAudio.prepareAudio(for: spaceship)
        self.spaceship = spaceship
        return spaceship
    }
}
