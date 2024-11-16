/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Spaceship related extensions for the ImmersiveViewModel.
*/

import QuartzCore
import RealityKit

extension ImmersiveViewModel {

    // Makes a spaceship, prepares it for flight in gameplay, fades it in, and starts up the audio.
    func spawnSpaceship() async throws -> ModelEntity {
        let spaceship = try await createSpaceship()
        spaceship.position = spaceshipInitialPosition()
        spaceship.fadeOpacity(from: 0, to: 1, duration: 1)
        try await spaceshipAudio.prepareAudio(for: spaceship)
        spaceshipAudio.play()
        return spaceship
    }

    // Makes a spaceship and applies base configuration to it for gameplay, then adds it to the
    // scene, and stores it for future use.
    func createSpaceship() async throws -> ModelEntity {

        // Get a base level configuration of the spaceship from the factory
        let spaceship = try await Entity.makeSpaceship()
        spaceship.scale = SIMD3<Float>(repeating: 1.25)

        // Configure it for flight
        spaceship.components.set(PhysicsMotionComponent())
        spaceship.components.set(ShipFlightComponent())
        spaceship.components.set(PrimaryThrustComponent())
        spaceship.components.set(EnvironmentLightingFadeComponent())
        spaceship.components.set(ShipVisualsComponent())
        spaceship.components.set(ShipAudioComponent())
        spaceship.components.set(AudioMaterialComponent(material: .plastic))

        // Add the spaceship to our scene
        rootEntity.addChild(spaceship)

        // Store the spaceship for future configuration
        self.spaceship = spaceship

        // Return the spaceship for downstream configuration
        return spaceship
    }

    func fadeOutSpaceship() async throws {

        guard let spaceship else { return }

        spaceship.components.remove(ShipControlComponent.self)
        spaceship.fadeOpacity(from: 1, to: 0, duration: 1)
        try await spaceshipAudio.fadeOut()

        try await Task.sleep(for: .seconds(1))

        spaceship.removeFromParent()
        self.spaceship = nil
    }

    func spaceshipInitialPosition() -> SIMD3<Float> {

        let offsetFromDevice: SIMD3<Float> = [0, -0.25, -0.75]

#if os(visionOS)
        let fallbackPosition: SIMD3<Float> = [0, 1.3, -1]

        if let deviceAnchor = headTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) {
            print("✅ Placing spaceship 1m directly in front of user.")
            let deviceTransform = deviceAnchor.originFromAnchorTransform
            return deviceTransform.translation + offsetFromDevice
        } else {
            print("⚠️ Could not determine device position. Placing spaceship at fallback location.")
            return fallbackPosition
        }
#else
        return offsetFromDevice
#endif
    }
}
