/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Game phase related extensions for the ImmersiveViewModel.
*/

import QuartzCore
import RealityKit

extension ImmersiveViewModel {

    // Enacts the choreography needed to smoothly transition between the game phases Joy Ride and Work.
    func transitionGamePhase(from previous: GamePhase, to current: GamePhase) async throws {
        switch (previous, current) {
        case (.joyRide, .joyRide):
            try await playJoyRideMusic()
            let spaceship = try await spawnSpaceship()
            // Enable hand controls after a second to prevent unexpected flight out of the gate
            try await Task.sleep(for: .seconds(1))
            spaceship.components.set(ShipControlComponent(parameters: .init()))

        case (.joyRide, .work):
            fadeOutJoyRideMusic(duration: 2)
            try await playWorkMusic()
            try await fadeOutSpaceship()
            let spaceship = try await spawnSpaceship()
            try await addTrailer()
            try await fadeInAstronomicalObjects()

            // Enable hand input control once the choreography is complete
            spaceship.components.set(ShipControlComponent(parameters: .init()))

            // In the Work game phase, the ship is liable to explode!
            spaceship.components.set(DamageComponent())

            // In the Work game phase, you may open a portal to outer space!
            prepareEntitiesForPortalCrossing()

        case (.work, .work):
            try await playWorkMusic()
            let spaceship = try await spawnSpaceship()
            try await addTrailer()

            // Enable hand controls after a second to prevent unexpected flight out of the gate
            try await Task.sleep(for: .seconds(1))
            spaceship.components.set(ShipControlComponent(parameters: .init()))

            // In the Work game phase, the ship is liable to explode!
            spaceship.components.set(DamageComponent())

            // In the Work game phase, you may open a portal to outer space!
            prepareEntitiesForPortalCrossing()

            try await fadeInAstronomicalObjects()

        case (.work, .joyRide):
            try await playJoyRideMusic()
            fadeOutWorkMusic(duration: 2)
            planetsAudio.fadeOut()
            try removeTrailer()
            try await fadeOutSpaceship()
            try await fadeOutAstronomicalObjects()
            let spaceship = try await spawnSpaceship()
            // Enable hand controls after a second to prevent unexpected flight out of the gate
            try await Task.sleep(for: .seconds(1))
            spaceship.components.set(ShipControlComponent(parameters: .init()))
        }
    }
}
