/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension of the entity class to load a model as a component and place entities in an orbit.
*/

import RealityKit

/// The extension of the entity class to create a component that loads a model
/// and a method that implements a halo effect for multiple models.
extension Entity {
    /// The name of the 3D model resource file.
    static var fileName: String = "rock"

    /// The model component loads a given file name.
    static var rockModel: ModelComponent = {
        let rock = try! Entity.loadModel(named: fileName)
        return rock.model!
    }()

    /// Assign a series of random rotations, translations, and scales for each rock model.
    func addHalo() {
        /// The number of models to generate.
        let modelCount: Int = 50

        // Create each model and apply a random transform, scale, and time interval.
        for _ in 0..<modelCount {
            /// The dedicated entity for the model and assign the model as a component.
            let entity = Entity()
            entity.components.set(Self.rockModel)

            /// The transform that contains a random rotation along the y-axis.
            let rotate0 = Transform(rotation: simd_quatf(angle: .random(in: 0...(2 * .pi)), axis: [0, 1, 0])).matrix

            /// The transform that adjusts along the z-axis.
            let translate = Transform(translation: [0, 0, 1]).matrix

            /// The transform that contains a random rotation along the y-axis.
            let rotate1 = Transform(rotation: simd_quatf(angle: .random(in: 0...(2 * .pi)), axis: [0, 1, 0])).matrix

            /// The transform that contains a random rotation along the x-axis.
            let rotate2 = Transform(rotation: simd_quatf(angle: .random(in: (-.pi / 9)...(.pi / 9)), axis: [1, 0, 0])).matrix

            // Assign the entity a transform based on the matrix product of each rotation and translation variable.
            entity.transform = Transform(matrix: rotate1 * rotate2 * translate * rotate0)

            // Assign the entity a random scale along all axis.
            entity.setScale(SIMD3(repeating: 0.001 * .random(in: 0.5...2)), relativeTo: entity)

            // Assign the entity's `TurnTableComponent` a random speed at which to rotate along the axis.
            entity.components.set(TurnTableComponent(
                speed: .random(in: 0.001...0.1),
                axis: [
                    .random(in: -1...1),
                    .random(in: -1...1),
                    .random(in: -1...1)]
            ))

            // Add the entity as a child.
            self.addChild(entity)
        }
    }
}
