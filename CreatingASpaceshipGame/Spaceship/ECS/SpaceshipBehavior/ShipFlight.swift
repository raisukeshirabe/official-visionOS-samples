/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Component and System for accelerating and rotating the spaceship.
*/

import RealityKit

struct ShipFlightComponent: Component {
    init() {
        ShipFlightSystem.registerSystem()
    }
}

final class ShipFlightSystem: System {

    static let query = EntityQuery(
        where: (
            .has(ShipFlightComponent.self) &&
            .has(ThrottleComponent.self) &&
            .has(PitchRollComponent.self)
        )
    )

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {

            let throttle = entity.components[ThrottleComponent.self]!.throttle
            let pitchRoll = entity.components[PitchRollComponent.self]!

            if entity.components[ShipFlightStateComponent.self] == nil {
                entity.components.set(ShipFlightStateComponent())
            }

            var flightState = entity.components[ShipFlightStateComponent.self]!

            let pitch = pitchRoll.pitch
            let roll = pitchRoll.roll

            let deltaTime = Float(context.deltaTime)
            let turnSpeed: Float = 1
            let maxPitchRoll: Float = 0.7

            let yawDelta = simd_quatf(angle: roll * deltaTime * turnSpeed, axis: .upward)
            flightState.yaw = (flightState.yaw * yawDelta).normalized

            let newRoll = simd_quatf(angle: -roll * maxPitchRoll, axis: .back)
            let newPitch = simd_quatf(angle: pitch * maxPitchRoll, axis: .left)
            flightState.pitchRoll = simd_slerp(flightState.pitchRoll, newRoll * newPitch, deltaTime * 2).normalized

            entity.transform.rotation = (flightState.yaw * flightState.pitchRoll).normalized
            entity.components[ShipFlightStateComponent.self] = flightState

            guard let physicsEntity = entity as? HasPhysics else { return }

            if entity.components.has(PrimaryThrustComponent.self) {
                let strength: Float = 40
                let primaryThrust = entity.transform.matrix.forward * throttle * strength * deltaTime
                physicsEntity.addForce(primaryThrust, relativeTo: nil)
            }

            guard let motion = physicsEntity.physicsMotion else { return }

            // Vertical component
            let shipUp = entity.transform.matrix.upward
            let vertVelocity = dot(motion.linearVelocity, shipUp)

            // Horizontal component
            let shipRight = entity.transform.matrix.right
            let rightVelocity = dot(motion.linearVelocity, shipRight)

            let verticalAssistStrength: Float = 80
            let assistiveThrust = -vertVelocity * shipUp * deltaTime * verticalAssistStrength +
                                  -rightVelocity * shipRight * deltaTime * verticalAssistStrength
            physicsEntity.addForce(assistiveThrust, relativeTo: nil)
        }
    }
}

struct ShipFlightStateComponent: Component {
    var yaw = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    var pitchRoll = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)

    init() {
        ShipFlightStateComponent.registerComponent()
    }
}

extension CollisionGroup {
    static let actualEarthGravity = CollisionGroup(rawValue: 100 << 0)
}

struct PrimaryThrustComponent: Component {}
