/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Component and System for managing spaceship control parameters.
*/

import RealityKit
import SwiftUI

@Observable
class ShipControlParameters {
    var throttle: Float = 0
    var pitch: Float = 0 // radians
    var roll: Float = 0 // radians

    func reset() {
        throttle = 0
        pitch = 0
        roll = 0
    }
}

struct ShipControlComponent: Component {
    let parameters: ShipControlParameters
}

final class ShipControlSystem: System {

    static var dependencies: [SystemDependency] = [.before(ShipFlightSystem.self)]
    static let query = EntityQuery(where: .has(ShipControlComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let shipControlComponent = entity.components[ShipControlComponent.self] else { return }
            let parameters = shipControlComponent.parameters
            entity.components.set([
                ThrottleComponent(throttle: parameters.throttle),
                PitchRollComponent(pitch: parameters.pitch, roll: parameters.roll)
            ])
        }
    }
}
