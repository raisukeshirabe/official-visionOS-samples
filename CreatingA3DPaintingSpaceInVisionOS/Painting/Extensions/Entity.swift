/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension of the entity class, to include a model component.
*/

import RealityKit

/// The extension of the `Entity` class to have a model component variable.
extension Entity {
    var model: ModelComponent? {
        get { components[ModelComponent.self] }
        set { components[ModelComponent.self] = newValue }
    }
}
