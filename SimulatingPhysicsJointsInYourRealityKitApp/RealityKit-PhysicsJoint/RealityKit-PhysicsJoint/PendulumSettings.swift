/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The pendulum settings that dictate the number of pendulums to create,
 as well as the size of the pendulums' components.
*/

import RealityKit

/// The settings for a pendulum setup, including the number of pendulums to create,
/// and the size of each component.
struct PendulumSettings {
    /// The radius of the ball in the pendulum.
    let ballRadius: Float = 0.04
    /// The mass of the ball in the pendulum.
    let ballMass: Float = 2
    /// The length of the pendulum string.
    let stringLength: Float = 0.3
    /// The radius of the pendulum string.
    let stringRadius: Float = 0.001
    /// The color of the pendulum string.
    let stringColor: Material.Color = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

    /// The size of the pendulum attachment.
    let attachmentSize: SIMD3<Float> = [2.0, 0.5, 2.0]
    /// The color of the pendulum attachment.
    let attachmentColor: Material.Color = #colorLiteral(red: 0.75, green: 0.88, blue: 0.75, alpha: 1.0)

    /// The number of pendulums the app creates.
    var pendulumCount: Int = 5

    /// The speed of the pendulum.
    ///
    /// This value affects the speed of the simulation system by modifying
    /// the scale of the entity that owns the `PhysicsSimulationComponent`.
    ///
    /// Use a value between `0.5` and `1.5`.
    let pendulumSpeed: Float = 0.5

    /// The impulse power to apply to the pendulum, based on the simulation speed.
    var impulsePower: SIMD3<Float> {
        assert(pendulumSpeed > 0)
        return [-2.0 / pow(pendulumSpeed, 4), 0, 0]
    }
}
