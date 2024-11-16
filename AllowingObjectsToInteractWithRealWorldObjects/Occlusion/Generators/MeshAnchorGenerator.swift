/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The class that detects anchors and updates the mesh.
*/

import SwiftUI
import RealityKit
import ARKit

/// The class retrieves anchors from `SceneReconstructionProvider`
/// and creates entities with occlusion material on these anchors.
class MeshAnchorGenerator {
    /// The root to hold the meshes that the app detects.
    var root: Entity?

    /// The collection that comprises the `MeshAnchor.id` and the entity associated with the anchors.
    private var anchors: [UUID: Entity] = [:]

    init(root: Entity) {
        self.root = root
    }
    
    /// Handles anchor update events by either adding, updating, or removing anchors from the collection.
    @MainActor
    func run(_ sceneRec: SceneReconstructionProvider) async {
        // Loop to process all anchor updates that the provider detects.
        for await update in sceneRec.anchorUpdates {
            switch update.event {
            case .added, .updated:
                // Retrieves the entity from the anchor collection based on the anchor ID.
                // If it doesn't exist, creates and adds a new entity to the collection.
                let entity = anchors[update.anchor.id] ?? {
                    let entity = Entity()
                    root?.addChild(entity)
                    anchors[update.anchor.id] = entity
                    return entity
                }()

                /// The occlusion material to apply to the entity.
                let material = OcclusionMaterial()

                /// The mesh based on the detected anchor.
                guard let mesh = try? await MeshResource(from: update.anchor) else { return }

                await MainActor.run {
                    // Update the entity mesh and apply the occlusion material.
                    entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

                    // Set the transform matrix on its position relative to the anchor.
                    entity.setTransformMatrix(update.anchor.originFromAnchorTransform, relativeTo: nil)
                }
            case .removed:
                // Remove the entity from the root if it exists.
                anchors[update.anchor.id]?.removeFromParent()
                
                // Remove the anchor entry from the dictionary.
                anchors[update.anchor.id] = nil
            }
        }
    }
}
