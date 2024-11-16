/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Collisions related extensions for the ImmersiveViewModel.
*/

import QuartzCore
import RealityKit

extension ImmersiveViewModel {

    func handleCollisionBegan(_ collision: CollisionEvents.Began) {

        guard shouldHandleCollision(collision) else { return }

        playAudio(for: collision)
        Task {
            try await handleGameplay(for: collision)
        }
    }

    func handleGameplay(for collision: CollisionEvents.Began) async throws {

        let entities = UnorderedPair(collision.entityA, collision.entityB)

        guard let spaceship = entities.first(where: { $0 == spaceship }),
            spaceship.components.has(DamageComponent.self)
        else {
            return
        }
        
        guard let other = entities.other(than: spaceship) else {
            return
        }

        if other.components.has(PlanetComponent.self) {
            try await handleShipCollisionWithPlanet(other)
        } else {
            addDamage(collision.impulse, to: spaceship)
        }
    }

    func handleShipCollisionWithPlanet(_ planet: Entity) async throws {

        guard
            let planetComponent = planet.components[PlanetComponent.self],
            planetComponent.hasBeenVisited == false
        else {
            return
        }

        let maxLevel = 7

        guard gameLevel <= maxLevel else {
            return try await spawnPortal()
        }

        // Mark this planet as visited
        planet.components[PlanetComponent.self]!.hasBeenVisited = true

        // Reduce gravitational effect
        planet.components.set(
            ForceEffectComponent(
                effect: ForceEffect(
                    effect: Gravity(minimumDistance: planetComponent.radius),
                    strengthScale: 0.33,
                    mask: .all.subtracting(.actualEarthGravity)
                )
            )
        )

        // Reduce transparency of visited planet
        planet.fadeOpacity(from: 1, to: 0.2, duration: 2)

        // Reduce level of tone so that the new tone will be relatively more present
        planetsAudio.controllers.last?.fade(to: -8, duration: 2)

        // Remove light component (because more than a couple point lights degrades performance)
        planet.findEntity(named: "Planet_Light")!.components.remove(PointLightComponent.self)

        try await addPlanet(gameLevel: gameLevel)

        // Bump up game level
        gameLevel += 1
    }

    func addPlanet(gameLevel: Int) async throws {

        let planet = try await addPlanet(radius: 0.5 / Float(gameLevel))
        guard let resource = planetsAudio.resourceByGameLevel[gameLevel] else {
            print("❌ Could not play audio for planet at gamel level \(gameLevel).")
            return
        }
        let controller = planet.prepareAudio(resource)
        controller.gain = -.infinity
        controller.fade(to: .zero, duration: 2)
        controller.play()
        planetsAudio.controllers.append(controller)
    }

    func addDamage(_ damage: Float, to spaceship: Entity) {
        let maxDamage: Float = 1
        let current = spaceship.components[DamageComponent.self]?.damage ?? .zero
        if current + damage > maxDamage {
            playSpaceshipExplosionAudio()
            spaceship.explode(parentingDebrisTo: rootEntity)
        } else {
            spaceship.components.set(DamageComponent(damage: current + damage))
        }
    }

    func shouldHandleCollision(_ collision: CollisionEvents.Began) -> Bool {
        // If the given pair of entities has collided too recently, wait until enough time has
        // passed to commit resources to handling collision.
        let entities = UnorderedPair(collision.entityA, collision.entityB)
        let now = CACurrentMediaTime()
        if let reference = debounce[entities] {
            if now - reference < Self.debounceThreshold {
                return false
            }
        }
        debounce[entities] = now
        return true
    }
}
