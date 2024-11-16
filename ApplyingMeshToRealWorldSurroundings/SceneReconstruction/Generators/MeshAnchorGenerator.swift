/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The class that detects anchors and updates the mesh.
*/

import RealityKit
import ARKit

/// The class retrieves anchors from `SceneReconstructionProvider`
/// and creates entities on these anchors.
class MeshAnchorGenerator {
    /// The root entity of the view.
    var root: Entity

    /// The collection of anchors.
    private var anchors: [UUID: Entity] = [:]

    init(root: Entity) {
        self.root = root
    }

    /// Handle anchor update events by either adding, updating, or removing anchors from the collection.
    @MainActor
    func run(_ sceneRec: SceneReconstructionProvider) async {
        // Loop to process all anchor updates that the provider detects.
        for await update in sceneRec.anchorUpdates {
            // Handle different types of anchor update events.
            switch update.event {
            case .added, .updated:
                // Retrives the entity from the anchor collection based on the anchor ID.
                // If it doesn't exist, creates and adds a new entity to the collection.
                let entity = anchors[update.anchor.id] ?? {
                    let entity = Entity()
                    root.addChild(entity)
                    anchors[update.anchor.id] = entity

                    return entity
                }()

                /// The material for the mesh to update.
                let material = SimpleMaterial(color: .cyan.withAlphaComponent(0.8), isMetallic: false)

                /// The mesh from an anchor.
                guard let mesh = try? await MeshResource(from: update.anchor) else { return }

                await MainActor.run {
                    // Update the entity mesh and apply the material.
                    entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

                    // Set the transform matrix on its position relative to the anchor.
                    entity.setTransformMatrix(update.anchor.originFromAnchorTransform, relativeTo: nil)
                }
            case .removed:
                // Remove the entity from the root.
                anchors[update.anchor.id]?.removeFromParent()

                // Remove the anchor entry from the collection.
                anchors[update.anchor.id] = nil
            }
        }
    }
}
