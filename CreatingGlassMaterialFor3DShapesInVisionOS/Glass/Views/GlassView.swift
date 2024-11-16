/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A reality view to load in a model and allow people to adjust the glass material.
*/

import SwiftUI
import RealityKit

/// A view that loads in a 3D model and applies a glass material to it.
struct GlassView: View {
    /// The default roughness value of the material.
    @State var roughness: Float = 0.2

    /// The default eta parameter for refraction.
    @State var eta: Float = 0.5

    /// The entity to store the dragon model.
    @State var entity: Entity?

    var body: some View {
        HStack {
            RealityView { content in
                do {
                    // Load the model from the filename.
                    let fileName = "DragonGlass.usda"
                    let entity = try await Entity(named: fileName)

                    // Adjust the scale and position of the model.
                    let scale: Float = 2
                    let position: SIMD3<Float> = [0.1, -0.15, 0.0]
                    entity.scale *= scale
                    entity.position += position

                    // Add the entity to the reality view.
                    content.add(entity)

                    // Set `entity` to the dragon model.
                    self.entity = entity
                } catch {
                    print("Error loading model: \(error)")
                }
            } update: { _ in
                entity?.updateMaterials({ material in
                    // Obtain the current material of the dragon model.
                    guard var mat = material as? ShaderGraphMaterial else { return }

                    do {
                        // Assign the roughness variable to the `roughness` parameter.
                        try mat.setParameter(name: "roughness", value: .float(roughness))
                        // Assign the eta variable to the `eta` parameter.
                        try mat.setParameter(name: "eta", value: .float(eta))
                    } catch {
                        print("Error setting parameters: \(error)")
                    }

                    // Update the dragon model's material.
                    material = mat
                })
            }

            Divider()

            // Set up a slider in the window to update the `roughness`
            // and `eta` parameter to a value between 0 and 1.
            VStack {
                HStack {
                    Text("Roughness"); Spacer(); Text("\(roughness)")
                }
                Slider(value: $roughness, in: 0...1)

                Divider()

                HStack {
                    Text("ETA:"); Spacer(); Text("\(eta)")
                }
                Slider(value: $eta, in: 0...1)
            }.frame(maxWidth: 200)
        }.padding()
    }
}

