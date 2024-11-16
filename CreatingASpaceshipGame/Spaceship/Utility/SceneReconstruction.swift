/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Class for managing ARKit scene reconstruction.
*/

#if os(visionOS)
import RealityKit
import ARKit

@MainActor
final class SceneReconstruction {

    let session = ARKitSession()
    var provider = SceneReconstructionProvider(modes: [.classification])

    let entity = Entity()
    var meshes: [UUID: Entity] = [:]

    func start() async throws {
        guard SceneReconstructionProvider.isSupported else { return }
        try await session.run([provider])
        prepareUpdates()
    }

    func stop() {
        session.stop()
        provider = SceneReconstructionProvider()
    }

    private func prepareUpdates() {
        Task { @MainActor in
            for await update in provider.anchorUpdates {
                let meshAnchor = update.anchor
                let shape = try await Task(priority: .background) {
                    try await ShapeResource.generateStaticMesh(from: meshAnchor)
                }.value

                switch update.event {
                case .added:
                    addMeshAnchor(meshAnchor, shape: shape)
                case .updated:
                    updateMeshAnchor(meshAnchor, shape: shape)
                case .removed:
                    removeMeshAnchor(meshAnchor)
                }
            }
        }
    }

    private func addMeshAnchor(_ meshAnchor: MeshAnchor, shape: ShapeResource) {

        let entity = Entity()
        entity.name = "SceneReconstructionMesh-\(meshAnchor.id)"

        // Move the mesh entity to the correct location.
        entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)

        // Add a static physics body component so it doesn't move during collision.
        entity.components.set(PhysicsBodyComponent(mode: .static))

        // Add a collision component to the mesh entity so virtual objects can collide with it.
        configureCollisions(for: entity, with: shape)

        // Add a mesh classification component to the mesh entity for lookup during a collision event.
        if let classifications = meshAnchor.geometry.classifications {
            configureClassification(for: entity, with: classifications)
        }

        // Store the mesh entity with an anchor identifier and add it to the entity hiearchy.
        self.meshes[meshAnchor.id] = entity
        self.entity.addChild(entity)
    }

    private func updateMeshAnchor(_ meshAnchor: MeshAnchor, shape: ShapeResource) {

        guard let entity = self.meshes.removeValue(forKey: meshAnchor.id) else {
            return
        }

        // Move the mesh entity to the correct location.
        entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)

        // Add a collision component to the mesh entity so virtual objects can collide with it.
        configureCollisions(for: entity, with: shape)

        // Add a mesh classification component to the mesh entity for lookup during a collision event.
        if let classifications = meshAnchor.geometry.classifications {
            configureClassification(for: entity, with: classifications)
        }

        // Update the stored mesh entity.
        meshes[meshAnchor.id] = entity
    }

    private func removeMeshAnchor(_ meshAnchor: MeshAnchor) {
        meshes[meshAnchor.id]?.removeFromParent()
        meshes.removeValue(forKey: meshAnchor.id)
    }

    private func configureCollisions(for entity: Entity, with shape: ShapeResource) {
        entity.components.set(
            CollisionComponent(
                shapes: [shape],
                isStatic: true,
                filter: CollisionFilter(group: .sceneUnderstanding, mask: .all)
            )
        )
    }

    private func configureClassification(for entity: Entity, with classifications: GeometrySource) {
        entity.components.set(
            AudioMaterialLookupComponent(audioMaterialPerFace: classifications.audioMaterialPerFace)
        )
    }
}

extension GeometrySource {
    var audioMaterialPerFace: [AudioMaterial] {
        (0..<count).map { index in
            let classification = buffer
                .contents()
                .advanced(by: offset + (stride * Int(index)))
                .assumingMemoryBound(to: MeshAnchor.MeshClassification.self)
                .pointee
            return AudioMaterial(classification: classification)
        }
    }
}

extension AudioMaterial {
    init(classification: MeshAnchor.MeshClassification) {
        switch classification {
        case .none, .wall, .ceiling, .table, .door, .stairs, .cabinet:
            self = .wood
        case .floor, .seat, .bed, .plant:
            self = .fabric
        case .window, .tv:
            self = .glass
        case .homeAppliance:
            self = .metal
        @unknown default:
            self = .none
        }
    }
}

#endif
