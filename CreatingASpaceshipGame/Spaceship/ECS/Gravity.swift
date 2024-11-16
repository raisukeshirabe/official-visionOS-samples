/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Implementation of the Gravity force effect.
*/

import RealityKit

struct Gravity: ForceEffectProtocol {
    // Declare rigid body attributes needed to compute the force effect.
    // In this case, you need the positions and distances.
    var parameterTypes: PhysicsBodyParameterTypes { [.position, .distance] }

    // Specify how the computed force is applied to all the affected rigid bodies.
    // For example `.acceleration` mode allows you to apply acceleration directly to the rigid bodies regardless of their masses.
    // In this case, apply the computed result as forces. That is, heavy objects will experience small acceleration.
    var forceMode: ForceMode { .force }

    // Specify the magnitude of the force. This is a custom property of the custom force.
    var gravityMagnitude: Float = 0.1

    // Specify the minimum distance of rigid bodies affected by gravity.
    var minimumDistance: Float = 0.2

    // Define an update function to compute forces.
    // The argument `parameters` contain all the parameters you declared in `parameterTypes`.
    func update(parameters: inout ForceEffectParameters) {

        guard let distances = parameters.distances,
              let positions = parameters.positions else { return }

        // `physicsBodyCount` indicates the total number of rigid bodies affected
        // by this custom force effect.
        for index in 0..<parameters.physicsBodyCount {

            let distance = distances[index]
            let position = positions[index]

            // There is a singularity at the origin; ignore any objects near the origin.
            guard distance > minimumDistance else { continue }

            let force = computeForce(position: position, distance: distance)
            parameters.setForce(force, index: index)
        }
    }

    func computeForce(position: SIMD3<Float>, distance: Float) -> SIMD3<Float> {

        // For each rigid body, its position is relative to the effect's origin.
        // Normalize the position to get the direction pointing toward the origin.
        let towardsCenter = normalize(position) * -1

        // Multiply with the force magnitude to compute the final force.
        return towardsCenter * gravityMagnitude / pow(distance, 2)
    }
}
