/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Astronomical objects related extensions for the ImmersiveViewModel.
*/

import QuartzCore
import RealityKit

extension ImmersiveViewModel {

    func fadeInAstronomicalObjects() async throws {

        guard astronomicalObjects == nil else { return }

        let objects = Entity()
        rootEntity.addChild(objects)
        astronomicalObjects = objects

        let offsetFromDevice: SIMD3<Float> = [0, 0.5, -2]

#if os(visionOS)
        let fallbackPosition: SIMD3<Float> = [0, 1.6, -2]

        if let deviceAnchor = headTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) {
            print("✅ Placing first planet 500cm above and 2m in front of user.")
            let deviceTransform = deviceAnchor.originFromAnchorTransform
            objects.position = deviceTransform.translation + [0, 0.5, -2]
        } else {
            print("⚠️ Could not determine device position. Placing planet at fallback location.")
            objects.position = fallbackPosition
        }
#else
        objects.position = offsetFromDevice
#endif

        let planet = try await Entity.makePlanet(radius: 0.12)
        planet.fadeOpacity(to: 1, duration: 1)
        objects.addChild(planet)

        for asteroid in try await Entity.makeAsteroids(count: 40, in: 1...3, with: Gravity()) {
            asteroid.fadeOpacity(to: 1, duration: 2)
            objects.addChild(asteroid)
        }
    }

    func fadeOutAstronomicalObjects() async throws {

        guard let astronomicalObjects else { return }

        for asteroid in astronomicalObjects.children.filter({ $0.components.has(AsteroidComponent.self) }) {
            asteroid.fadeOpacity(to: 0, duration: 1)
        }

        for planet in astronomicalObjects.children.filter({ $0.components.has(PlanetComponent.self) }) {
            planet.fadeOpacity(to: 0, duration: 2)
        }

        try await Task.sleep(for: .seconds(2))

        astronomicalObjects.removeFromParent()
        self.astronomicalObjects = nil
    }

    func addPlanet(radius: Float) async throws -> Entity {
        let planet = try await Entity.makePlanet(radius: radius)
        planet.fadeOpacity(from: 0, to: 1, duration: 3)
        
        // Apply a default position to the planet for iOS, or if the sample is unable to obtain device position.
        // Fallback to a random position which may place a planet outside of the scene reconstruction mesh.
        planet.position = [
            .random(in: -2...2),
            .random(in: 0...2),
            .random(in: -3...0.5)
        ]
        
        astronomicalObjects?.addChild(planet)

#if os(visionOS)
        // Position the new planet randomly within the scene understanding bounds, from 1.5m to 4m away from the user.
        let minDistance: Float = 1.5
        let maxDistance: Float = 4
        if let scene = rootEntity.scene,
           let deviceAnchor = headTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) {
            // Cast a ray from the device position in a random direction
            let rayOrigin = deviceAnchor.originFromAnchorTransform.translation
            let rayDirection: SIMD3<Float> = [
                .random(in: -1...1),
                .random(in: -1...1),
                .random(in: -1...1)
            ]
            let rayCastResults = scene.raycast(
                origin: rayOrigin,
                direction: rayDirection,
                length: maxDistance,
                query: .nearest,
                mask: .sceneUnderstanding,
                relativeTo: nil
            )

            if let result = rayCastResults.first {
                // The ray intersected with the scene reconstruction mesh, so position the planet
                // along the angle of the intersection, inset by diameter of the planet
                let length = (result.position - rayOrigin).length()
                if length - radius * 2 > minDistance {
                    // If the intersection is within a valid range, place the planet somewhere along
                    // the angle of the intersection, randomly between the minimum and maximum
                    // distances.
                    let distance = Float.random(in: minDistance...length - radius * 2)
                    let position = rayOrigin + rayDirection * distance
                    planet.setPosition(position, relativeTo: nil)
                } else {
                    // If the intersection is closer than the minimum length, place it at the
                    // minimum distance.
                    let position = rayOrigin + rayDirection * minDistance
                    planet.setPosition(position, relativeTo: nil)
                }
            } else {
                // The ray did not intersect with the scene reconstruction mesh, so position the
                // planet along the angle of the ray cast anywhere between the minimum and maximum
                // distances.
                let distance = Float.random(in: minDistance...maxDistance)
                let position = rayOrigin + rayDirection * distance
                planet.setPosition(position, relativeTo: nil)
            }
        }
        #endif

        return planet
    }
}
