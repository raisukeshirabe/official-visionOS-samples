/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that creates an entity to generate texture.
*/

import SwiftUI
import RealityKit

/// A view that loads a torus model that generates materials in real time.
struct EntityView: View {
    /// The value that controls which iteration of the texture the generator uses.
    var seed: Int

    /// Load a file as an entity, scale to the proper size, and apply the `updateEntity` function.
    @MainActor
    func makeEntity() throws -> ModelEntity {
        /// The name of the model.
        let fileName: String = "Torus"
        
        /// The 3D torus model.
        let entity = try Entity.loadModel(named: fileName)

        // Set the scale of the entity with the bounding radius of the model's visible bounds.
        entity.scale /= entity.visualBounds(relativeTo: nil).boundingRadius

        let scale: Float = 0.2
        
        // Apply the scale factor with the value of the scale variable.
        entity.scale *= scale
        
        // Rotate the entity along the y-axis so that the entity faces the user.
        entity.transform.rotation *= simd_quatf(from: SIMD3<Float>(0, 1, 0), to: SIMD3<Float>(0, 0, 1))

        // Run the `updateEntity` function with the entity.
        try updateEntity(entity)

        return entity
    }
    
    /// Generate a texture, a new material, and a material sampler, and apply the result to the entity.
    @MainActor
    func updateEntity(_ entity: ModelEntity) throws {
        /// The texture based on the seed values.
        let texture = try ProceduralTextureGenerator.generate(seed)

        /// The texture of the sampler, to the nearest pixel.
        var sampler = PhysicallyBasedMaterial.Texture.Sampler()
        sampler.modify { $0.magFilter = .nearest }

        /// The material that simulates the appearance of real-world objects.
        var material = PhysicallyBasedMaterial()

        /// The texture for the material.
        let textureAndSampler = PhysicallyBasedMaterial.Texture(
            texture,
            sampler: sampler
        )
        
        // Set it as the material's base color.
        material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: textureAndSampler)

        // Apply the material to the model of the entity.
        entity.model?.materials = [material]

        // Initalize the texture.
        entity.components[DrawableQueueComponent.self] = try DrawableQueueComponent(texture: texture)
    }

    /// The main body of the view.
    var body: some View {
        RealityView { content in
            do {
                let entity = try makeEntity()
                content.add(entity)
            } catch {
                print("Error creating entity: \(error)")
            }
        } update: { content in
            for entity in content.entities {
                if let modelEntitty = entity as? ModelEntity {
                    // Attempt to update each entity in scene updates.
                    try? updateEntity(modelEntitty)
                } else {
                    print("Entity is not a ModelEntity.")
                }
            }
        }
    }
}
