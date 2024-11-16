/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A component that marks an entity as a plant.
*/

import Foundation
import RealityKit

public extension Entity {
    var plantComponent: PlantComponent? {
        get { components[PlantComponent.self] }
        set { components[PlantComponent.self] = newValue }
    }
    
    /// Recursive search of children looking for any descendants with a specific component and calling a closure with them.
    func forEachDescendant<T: Component>(withComponent componentClass: T.Type, _ closure: (Entity, T) -> Void) {
        for child in children {
            if let component = child.components[componentClass] {
                closure(child, component)
            }
            child.forEachDescendant(withComponent: componentClass, closure)
        }
    }
    
    var modelComponent: ModelComponent? {
        get { components[ModelComponent.self] }
        set { components[ModelComponent.self] = newValue }
    }
    
    var animationLibraryComponent: AnimationLibraryComponent? {
        get { components[AnimationLibraryComponent.self] }
        set { components[AnimationLibraryComponent.self] = newValue }
    }
}
