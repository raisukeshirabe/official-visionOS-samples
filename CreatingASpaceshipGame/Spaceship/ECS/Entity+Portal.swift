/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Portal related Entity extensions.
*/

import RealityKit
import RealityKitContent
import ImageIO

extension Entity {

    static func makePortalToOuterspace() async throws -> Entity {
        let portal = Entity()
        portal.name = "Portal"
        let outerspace = try await makeOuterspace()
        portal.addChild(outerspace)
        portal.components.set(
            PortalComponent(
                target: outerspace,
                clippingMode: .plane(.positiveZ),
                crossingMode: .plane(.positiveZ)
            )
        )

        let dimension: Float = 0.8
        portal.components.set(
            ModelComponent(
                mesh: .generatePlane(width: dimension, height: dimension, cornerRadius: dimension / 2),
                materials: [PortalMaterial()]
            )
        )

        let portalParticles = try! await Entity(named: "PortalParticles.usda", in: realityKitContentBundle)
        portalParticles.position = [0, 0, 0.01]
        portalParticles.scale = SIMD3<Float>(repeating: 0.8 / 1.0)
        portal.addChild(portalParticles)

        return portal
    }

    // Create a large backdrop of outer space viewed through the portal.
    static func makeOuterspace() async throws -> Entity {
        
        // Create an outer space "world".
        let outerspace = Entity()
        outerspace.components.set(WorldComponent())
        outerspace.name = "Outer Space"

        try await makeSunlightIBL(world: outerspace)

        // Attach the material to a large sphere.
        let material = try await makeStarFieldMaterial()

        let starfield = Entity()
        starfield.components.set(
            ModelComponent(
                mesh: .generateSphere(radius: 20),
                materials: [material]
            )
        )

        // Ensure the texture image points inward at the viewer.
        starfield.scale *= .init(x: -1, y: 1, z: 1)
        outerspace.addChild(starfield)

        // Add the planet and an asteroid belt.
        let planetEntity = Entity()
        let planet = try await Entity.makePlanet(radius: 0.24)

        // Mark the planet as visited avoiding continued game play.
        planet.components[PlanetComponent.self]!.hasBeenVisited = true

        let asteroids = try await Entity.makeAsteroids(count: 25, in: 1...4, with: Gravity())
        for asteroid in asteroids {
            var collision = asteroid.components[CollisionComponent.self]!
            collision.filter = .init(group: .all, mask: .all.subtracting(.sceneUnderstanding))
            asteroid.components.set(collision)
            planetEntity.addChild(asteroid)
        }
        planetEntity.addChild(planet)
        planetEntity.position = [0, 0, -5]
        outerspace.addChild(planetEntity)

        return outerspace
    }

    // Create a material with a starfield on it.
    static func makeStarFieldMaterial() async throws -> UnlitMaterial {
        let resource = try await TextureResource(named: "Starfield")
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        return material
    }

    static func makeSunlightIBL(world: Entity) async throws {
        guard let url = Bundle.main.url(forResource: "Sunlight", withExtension: "png") else {
            return
        }

        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        let ibl = try! await EnvironmentResource(equirectangular: image)
        world.components.set(ImageBasedLightComponent(source: .single(ibl), intensityExponent: 12))
        world.components.set(ImageBasedLightReceiverComponent(imageBasedLight: world))
    }
}
