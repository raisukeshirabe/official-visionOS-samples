/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Planet related Entity extensions.
*/

import Foundation
import QuartzCore
import RealityKit
import RealityKitContent

struct PlanetNames {
    static let color1: String = "Color1"
    static let color2: String = "Color2"
    static let subplanet: String = "Planet_01"
    static let resource: String = "Planet"
    static let planetLight: String = "Planet_Light"
}

struct PlanetVisualsComponent: Component {
    let hue1: CGFloat
    let hue2: CGFloat

    init(hue1: CGFloat, hue2: CGFloat) {
        self.hue1 = hue1
        self.hue2 = hue2

        PlanetVisualsComponent.registerComponent()
        PlanetVisualsSystem.registerSystem()
    }
}

class PlanetVisualsSystem: System {

    var elapsedTime: TimeInterval = 0

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        elapsedTime += context.deltaTime

        for entity in context.entities(matching: EntityQuery(where: .has(PlanetVisualsComponent.self)), updatingSystemWhen: .rendering) {
            guard let visualsComponent = entity.components[PlanetVisualsComponent.self] else { continue }
            guard let subPlanet = entity.findEntity(named: PlanetNames.subplanet) else { continue }

            if var shaderGraphMaterial = subPlanet.components[ModelComponent.self]?.materials.first as? ShaderGraphMaterial {
                let strength = cos(elapsedTime).map(from: -1...1, to: 0.6...1)
                let brightness = strength * 0.9

                try! shaderGraphMaterial.setParameter(
                    name: PlanetNames.color1,
                    value: .color(.init(hue: visualsComponent.hue1 / 360, saturation: 0.85, brightness: brightness, alpha: 1))
                )

                subPlanet.components[ModelComponent.self]!.materials = [shaderGraphMaterial]
            }
        }
    }
}
extension Entity {
    static func makePlanet(radius: Float = 0.25) async throws -> Entity {

        let planet = try await Entity(named: PlanetNames.resource, in: realityKitContentBundle)
        planet.scale *= radius

        // Add a custom planet component to keep track of when the spaceship visits it.
        planet.components.set(PlanetComponent(radius: radius))

        // Add gravity so the asteroids orbit around the planet.
        let gravity = ForceEffect(effect: Gravity(minimumDistance: radius),
                                  mask: .all.subtracting(.actualEarthGravity))
        planet.components.set(ForceEffectComponent(effect: gravity))

        // Add physics motion to spin the planet around.
        planet.components.set(PhysicsMotionComponent(angularVelocity: [0, 1, 0] * 0.3))

        // Add collision component so the ship can visit the planet and proceed to the next game level.
        planet.components.set(CollisionComponent(shapes: [.generateSphere(radius: 1)]))

        let subPlanet = planet.findEntity(named: PlanetNames.subplanet)!
        let hue1: CGFloat = .random(in: 180...400).truncatingRemainder(dividingBy: 360)
        let hue2: CGFloat = .random(in: 180...400).truncatingRemainder(dividingBy: 360)

        planet.components.set(PlanetVisualsComponent(hue1: hue1, hue2: hue2 ))

        if var shaderGraphMaterial = subPlanet.components[ModelComponent.self]?.materials.first as? ShaderGraphMaterial {

            try shaderGraphMaterial.setParameter(
                name: PlanetNames.color1,
                value: .color(.init(hue: hue1 / 360, saturation: 0.85, brightness: 0.9, alpha: 1))
            )

            try shaderGraphMaterial.setParameter(
                name: PlanetNames.color2,
                value: .color(.init(hue: hue2 / 360, saturation: 0.85, brightness: 0.9, alpha: 1))
            )

            subPlanet.components[ModelComponent.self]!.materials = [shaderGraphMaterial]
        }

        let lightColor = PointLightComponent.Color(hue: hue1 / 360, saturation: 0.85, brightness: 0.9, alpha: 1)
        
        subPlanet.findEntity(named: PlanetNames.planetLight)!.components[PointLightComponent.self]!.color = lightColor

        return planet
    }

    static func makeAsteroids(count: Int, in orbitRange: ClosedRange<Float>, with gravity: Gravity) async throws -> [Entity] {

        let asteroids = try await Entity(named: "AsteroidsAssembly", in: realityKitContentBundle)

        guard let variantsParent = asteroids.findEntity(named: "Asteroids") else { return [] }

        var variants: [Entity] = []
        for variant in variantsParent.children {
            let entity = variant

            // Add collision shape.
            let radius = entity.visualBounds(recursive: true, relativeTo: nil).extents.x / 2

            let shape: ShapeResource = .generateSphere(radius: radius)
            entity.components.set(CollisionComponent(shapes: [shape]))

            // Add the physics body.
            var physicsBody = PhysicsBodyComponent(shapes: [shape], mass: 1, mode: .dynamic)
            physicsBody.isAffectedByGravity = false
            physicsBody.linearDamping = 0
            physicsBody.angularDamping = 0
            entity.components.set(physicsBody)

            entity.components.set(AsteroidComponent())
            entity.components.set(AudioMaterialComponent(material: .rock))
            entity.components.set(PortalCrossingComponent())

            variants.append(entity)
        }

        return (0..<count).map { index in

            // Create a meteoroid from one of the variants.
            let asteroid = variants[.random(in: 0..<variants.count)].clone(recursive: true)
            asteroid.name = "Asteroid_\(index)"

            // Generate a random radius.
            let radius: Float = .random(in: orbitRange)

            // Generate a random rotation angle.
            let theta: Float = .random(in: .zero ... 2 * .pi)

            // Place the meteoroid on the XZ plane.
            asteroid.position = [sin(theta) * radius, 0, cos(theta) * radius]

            // The velocity direction is tangential to the radial direction.
            let orbitVelocity = calculateVelocity(radius: radius, angle: theta, gravityMagnitude: gravity.gravityMagnitude)

            // Give each meteoroid a random angular velocity.
            let angularDirection: SIMD3<Float> = normalize([.random(in: 0...1), .random(in: 0...1), .random(in: 0...1)])
            asteroid.components.set(PhysicsMotionComponent(linearVelocity: orbitVelocity,
                                                           angularVelocity: angularDirection * .pi / 3))
            return asteroid
        }
    }

    static func calculateVelocity(radius: Float, angle: Float, gravityMagnitude: Float) -> SIMD3<Float> {

        // Give the meteoroid a velocity that produces a circular orbit.
        let orbitSpeed = sqrt(gravityMagnitude / radius)

        // The velocity direction is tangential to the radial direction.
        let orbitDirection: SIMD3<Float> = [cos(angle), 0, -sin(angle)]

        return orbitDirection * orbitSpeed
    }

}
