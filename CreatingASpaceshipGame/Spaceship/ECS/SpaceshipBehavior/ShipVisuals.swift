/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Component and System for updating spaceship's appearance and partciles.
*/

import RealityKit

final class ShipVisualsSystem: System {

    static let query = EntityQuery(where: .has(ThrottleComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {

            let throttle = entity.components[ThrottleComponent.self]!.throttle

            for engineName in ["LeftEngine", "RightEngine"] {
                let engine = entity.findEntity(named: engineName)!
                let exhaust = engine.findEntity(named: "Exhaust")!
                updateExhaust(exhaust, throttle: throttle)
                let particles = engine.findEntity(named: "ParticleEmitter")!
                updateVaporTrail(particles, throttle: throttle)

                if let physicsMotion = entity.components[PhysicsMotionComponent.self] {
                    let forwardVelocity = dot(physicsMotion.linearVelocity, entity.transform.matrix.forward)
                    let wingTip = engine.findEntity(named: "WingTip")!
                    updateWingTip(wingTip, forwardVelocity: forwardVelocity)
                }
            }
        }
    }

    func updateExhaust(_ exhaust: Entity, throttle: Float) {
        exhaust.transform.scale.z = (throttle / 5) + 0.4
    }

    func updateVaporTrail(_ vaporTrail: Entity, throttle: Float) {
        var particleEmitter = vaporTrail.components[ParticleEmitterComponent.self]!
        particleEmitter.mainEmitter.lifeSpan = Double(throttle) * 0.1
        vaporTrail.components.set(particleEmitter)
    }

    func updateWingTip(_ wingTip: Entity, forwardVelocity: Float) {
        guard var particleEmitter = wingTip.components[ParticleEmitterComponent.self] else { return }
        particleEmitter.mainEmitter.birthRate = sqrt(forwardVelocity) * 500
        particleEmitter.mainEmitter.lifeSpan = Double(forwardVelocity * 0.1)
        wingTip.components.set(particleEmitter)
    }
}

struct ShipVisualsComponent: Component {
    init() {
        ShipVisualsSystem.registerSystem()
    }
}
