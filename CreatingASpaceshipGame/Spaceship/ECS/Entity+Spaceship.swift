/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Spaceship related Entity extensions.
*/

import RealityKit
import RealityKitContent

extension Entity {

    static func makeSpaceship() async throws -> ModelEntity {

        // The spaceship uses physics forces and collisions. By declaring it as a `ModelEntity`,
        // it inherits the functionality afforded by the `HasPhysics` protocol.
        let spaceship = ModelEntity()
        spaceship.name = "Spaceship"

        let shipModel = try await Entity(named: "ShipAssembly", in: realityKitContentBundle)
        shipModel.name = "ShipModel"
        spaceship.addChild(shipModel)

        var physicsBody = PhysicsBodyComponent(mode: .dynamic)
        physicsBody.isAffectedByGravity = false
        physicsBody.linearDamping = 0.2
        physicsBody.massProperties.mass = 0.4
        spaceship.components.set(physicsBody)

        let bodyCollisionShape = ShapeResource
            .generateCapsule(height: 0.1, radius: 0.015)
            .offsetBy(rotation: .init(angle: .pi / 2, axis: [1, 0, 0]))

        let wingsCollisionShape = ShapeResource
            .generateCapsule(height: 0.11, radius: 0.015)
            .offsetBy(rotation: .init(angle: .pi / 2, axis: [1, 0, 0]))
            .offsetBy(rotation: .init(angle: .pi / 2, axis: [0, 1, 0]))
            .offsetBy(translation: [0, 0, 0.02])

        spaceship.components.set(
            CollisionComponent(
                shapes: [
                    bodyCollisionShape,
                    wingsCollisionShape
                ],
                filter: .init(group: .actualEarthGravity, mask: .all)
            )
        )

        // Add a headlight to the spaceship.
        addHeadlight(to: spaceship)

        shipModel.findEntity(named: "Exploded")?.isEnabled = false

        for engineName in ["LeftEngine", "RightEngine"] {
            let engine = shipModel.findEntity(named: engineName)!
            try await configureEngineAudioSource(on: engine)
        }

        spaceship.components.set(ThrottleComponent())
        spaceship.components.set(PitchRollComponent())
        spaceship.components.set(ShipAudioComponent())
        spaceship.components.set(ShipVisualsComponent())

        return spaceship
    }
    
    static func addHeadlight(to spaceship: Entity) {
        if let headLightEntity = spaceship.findEntity(named: "HeadLight") {
            var spotLight = SpotLightComponent(
                color: .init(
                    red: 255.0 / 255.0,
                    green: 233.0 / 255.0,
                    blue: 138.0 / 255.5,
                    alpha: 1.0
                )
            )
            spotLight.intensity = 7000
            spotLight.attenuationRadius = 20
            spotLight.innerAngleInDegrees = 45
            spotLight.outerAngleInDegrees = 60
            
            var spotLightShadow = SpotLightComponent.Shadow()
            spotLightShadow.zFar = .fixed(20)
            headLightEntity.components.set([spotLight, spotLightShadow])
        }
    }

    static func configureEngineAudioSource(on spaceship: Entity) async throws {
        try await configureEngineTurbineAudioSource(on: spaceship)
        try await configureEngineExhaustAudioSource(on: spaceship)
        try await configureVaporTrailAudioSource(on: spaceship)
    }

    static func configureEngineTurbineAudioSource(on spaceship: Entity) async throws {
        let audioSource = Entity()
        audioSource.name = "AudioSource-EngineTurbine"
        audioSource.orientation = .init(angle: .pi, axis: [0, 1, 0])
        audioSource.components.set(SpatialAudioComponent(directivity: .beam(focus: 0.25)))
        spaceship.addChild(audioSource)
    }

    static func configureEngineExhaustAudioSource(on spaceship: Entity) async throws {
        // This audio source plays back audio for the jet exhaust represented visually with a blue
        // glowing cone which gets larger in response to the throttle. Accordingly, the loudness of
        // this audio source is modulated by the throttle.
        let audioSource = Entity()
        audioSource.name = "AudioSource-EngineExhaust"
        audioSource.orientation = .init(angle: .pi, axis: [0, 1, 0])
        audioSource.components.set(SpatialAudioComponent(directivity: .beam(focus: 0.25)))
        spaceship.addChild(audioSource)
    }

    static func configureVaporTrailAudioSource(on spaceship: Entity) async throws {
        // This audio source plays back audio for the engine condensation represented visually with
        // a smokey particle effect. The loudness of this audio source isn't modulated by the
        // throttle of the ship, as it's always fizzling.
        let audioSource = Entity()
        audioSource.name = "AudioSource-EngineParticles"
        audioSource.orientation = .init(angle: .pi, axis: [0, 1, 0])
        audioSource.components.set(SpatialAudioComponent(directivity: .beam(focus: 0.25)))
        spaceship.addChild(audioSource)
    }

    func explode(parentingDebrisTo newParent: Entity) {

        guard let exploded = findEntity(named: "Exploded") else { return }

        // The linear velocity of this entity.
        let linearVelocity = components[PhysicsMotionComponent.self]?.linearVelocity ?? .zero

        for piece in exploded.children {

            piece.setParent(newParent, preservingWorldTransform: true)

            var physicsBody = PhysicsBodyComponent()
            physicsBody.isAffectedByGravity = false
            physicsBody.massProperties.mass = 0.1
            physicsBody.linearDamping = 0
            piece.components.set(physicsBody)

            let randomVelocity: SIMD3<Float> = [
                .random(in: -1...1),
                .random(in: -1...1),
                .random(in: -1...1)
            ]

            let modifiedVelocity = randomVelocity * linearVelocity
            let physicsMotion = PhysicsMotionComponent(linearVelocity: modifiedVelocity)
            piece.components.set(physicsMotion)

            var collision = CollisionComponent(
                shapes: [.generateBox(size: .init(repeating: 0.01))]
            )
            collision.filter = .init(group: .actualEarthGravity, mask: .all)

            piece.components.set(AudioMaterialComponent(material: .plastic))

            piece.components.set(collision)
        }

        removeFromParent()
    }

    func fadeOpacity(from start: Float? = nil, to end: Float, duration: Double) {
        let start = start ?? components[OpacityComponent.self]?.opacity ?? 0
        let fadeInAnimationDefinition = FromToByAnimation(
            from: Float(start),
            to: Float(end),
            duration: duration,
            timing: .easeInOut,
            bindTarget: .opacity
        )
        let fadeInAnimation = try! AnimationResource.generate(with: fadeInAnimationDefinition)
        components.set(OpacityComponent(opacity: start))
        playAnimation(fadeInAnimation)
    }
}
