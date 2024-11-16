/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that dynamically loads a left and right texture and creates a stereoscopic image.
*/

import RealityKit

/// A class that handles the creation of a stereoscopic image entity.
public class StereoImageCreator {
    /// Load textures and apply to the box.
    @MainActor private func applyTextureToEntity(box: ModelEntity, material: inout ShaderGraphMaterial) async {
        do {
            /// The name of the resource for the left texture.
            let leftFileName = "Shop_L"

            /// The name of the resource for the right texture.
            let rightFileName = "Shop_R"

            /// The left texture for the shader graph material.
            let leftTexture = try await TextureResource(named: leftFileName)

            /// The right texture for the shader graph material.
            let rightTexture = try await TextureResource(named: rightFileName)

            /// The parameter name to modify the left texture in the shader graph.
            let leftParameter = "LeftTexture"

            /// The parameter name to modify the right texture in the shader graph.
            let rightParameter = "RightTexture"

            // Set the textures into the shader graph material.
            try material.setParameter(name: leftParameter, value: .textureResource(leftTexture))
            try material.setParameter(name: rightParameter, value: .textureResource(rightTexture))

            // Apply the results to the material and assign to the box's material.
            box.model?.materials = [material]
        } catch {
            // Handle any errors that occur.
            assertionFailure("\(error)")
        }
    }
    
    /// Creates and returns the stereoscopic image entity.
    @MainActor public func createImageEntity() async -> ModelEntity? {
        /// The full path to the material primitive in the usda file.
        let materialRoot: String = "/Root/Material"

        /// The filename of the material.
        let materialName: String = "StereoscopicMaterial"

        /// The shader graph material for the stereoscopic image.
        guard var material = try? await ShaderGraphMaterial(named: materialRoot, from: materialName) else {
            print("Failed to load shader graph material.")
            return nil
        }

        /// The size of the box in three dimensions.
        let size: Float = 0.3

        /// The z-axis scale to compress the box into an image placeholder.
        let zScale: Float = 1E-3

        // Generates the model entity in the shape of a box and applies the shader graph material.
        let box = ModelEntity(
            mesh: .generateBox(size: size),
            materials: [material]
        )

        // Apply the z-axis scale to compress the box into a flat plane.
        box.scale.z = zScale

        // Load textures and apply to the box.
        await applyTextureToEntity(box: box, material: &material)

        return box
    }
}
