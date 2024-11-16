/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view to load in a model of a car that people can manipulate with gestures.
*/

import SwiftUI
import RealityKit

/// A view that creates two custom gestures and a car model
/// that can respond to gestures to move and scale the entity.
struct CarView: View {
    /// The initial position of the entity.
    @State var initialPosition: SIMD3<Float>? = nil
    
    /// The initial scale of the entity.
    @State var initialScale: SIMD3<Float>? = nil
    
    /// The gesture checks whether there is a root component and adjusts the postion of the entity.
    var translationGesture: some Gesture {
        /// The gesture to move an entity.
        DragGesture()
            .targetedToAnyEntity()
            .onChanged({ value in
                /// The entity that the drag gesture targets.
                let rootEntity = value.entity

                // Set `initialPosition` to the position of the entity if it is `nil`.
                if initialPosition == nil {
                    initialPosition = rootEntity.position
                }

                /// The movement that converts a global world space to the scene world space of the entity.
                let movement = value.convert(value.translation3D, from: .global, to: .scene)

                // Apply the entity position to match the drag gesture,
                // and set the movement to stay at the ground level.
                rootEntity.position = (initialPosition ?? .zero) + movement.grounded
            })
            .onEnded({ _ in
                // Reset the `initialPosition` back to `nil` when the gesture ends.
                initialPosition = nil
            })
    }
    
    /// The gesture checks whether there is a root component and adjusts the scale of the entity.
    var scaleGesture: some Gesture {
        /// The gesture to scale the entity with two hands.
        MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                /// The entity that the magnify gesture targets.
                let rootEntity = value.entity

                // Set the `initialScale` to the scale of the entity if it is `nil`.
                if initialScale == nil {
                    initialScale = rootEntity.scale
                }

                /// The rate that the model will scale by.
                let scaleRate: Float = 1.0

                // Scale the entity up smoothly by the relative magnification on the gesture.
                rootEntity.scale = (initialScale ?? .init(repeating: scaleRate)) * Float(value.gestureValue.magnification)
            }
            .onEnded { _ in
                // Reset the `initialScale` back to `nil` when the gesture ends.
                initialScale = nil
            }
    }
    
    /// The body loads a model, applies a collision box, and enables gesture inputs.
    var body: some View {
        RealityView { content in
            /// The name of the model.
            let fileName: String = "Huracan-EVO-RWD-Spyder-opt-22"
            
            /// The model that loads from the filename asynchronously.
            guard let car = try? await ModelEntity(named: fileName) else {
                assertionFailure("Failed to load model: \(fileName)")
                return
            }

            /// The visual bounds of the car.
            let bounds = car.visualBounds(relativeTo: nil)
            
            /// The width of the collision box by the size of the model.
            let carWidth: Float = (car.model?.mesh.bounds.max.x)!
            
            /// The height of the collision box by the size of the model.
            let carHeight: Float = (car.model?.mesh.bounds.max.y)!
            
            /// The depth of the collision box by the size of the model.
            let carDepth: Float = (car.model?.mesh.bounds.max.z)!
            
            /// The box around the model of the car for collisions.
            let boxShape = ShapeResource.generateBox(
                width: carWidth,
                height: carHeight,
                depth: carDepth)

            // Add a box shape as a collision component.
            car.components.set(CollisionComponent(shapes: [boxShape]))
            
            // Enable inputs from the hand gestures.
            car.components.set(InputTargetComponent())
            
            // Set the spawn position of the entity on the ground.
            car.position.y -= bounds.min.y
            
            // Set the spawn position along the z-axis, with the edge of the visual bound.
            car.position.z += bounds.min.z

            // Set the spawn position along the x-axis, with the edge of the visual bound.
            car.position.x += bounds.min.x

            car.scale /= 1.5

            // Add the car model to the `RealityView`.
            content.add(car)
        }
        // Enable the `translationGesture` to the `RealityView`.
        .gesture(translationGesture)
        // Enable the `scaleGesture` to the `RealityView`.
        .gesture(scaleGesture)
    }
}
