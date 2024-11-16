/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The class that loads available USDZs and reports loading progress.
*/

import Foundation
import RealityKit

@MainActor
@Observable
final class ModelLoader {
    private var didStartLoading = false
    private(set) var progress: Float = 0.0
    private(set) var placeableObjects = [PlaceableObject]()
    private var fileCount: Int = 0
    private var filesLoaded: Int = 0
    
    init(progress: Float? = nil) {
        if let progress {
            self.progress = progress
        }
    }
    
    var didFinishLoading: Bool { progress >= 1.0 }
    
    private func updateProgress() {
        filesLoaded += 1
        if fileCount == 0 {
            progress = 0.0
        } else if filesLoaded == fileCount {
            progress = 1.0
        } else {
            progress = Float(filesLoaded) / Float(fileCount)
        }
    }

    func loadObjects() async {
        // Only allow one loading operation at any given time.
        guard !didStartLoading else { return }
        didStartLoading.toggle()

        // Get a list of all USDZ files in this app’s main bundle and attempt to load them.
        var usdzFiles: [String] = []
        if let resourcesPath = Bundle.main.resourcePath {
            try? usdzFiles = FileManager.default.contentsOfDirectory(atPath: resourcesPath).filter { $0.hasSuffix(".usdz") }
        }
        
        assert(!usdzFiles.isEmpty, "Add USDZ files to the '3D models' group of this Xcode project.")
        
        fileCount = usdzFiles.count
        await withTaskGroup(of: Void.self) { group in
            for usdz in usdzFiles {
                let fileName = URL(string: usdz)!.deletingPathExtension().lastPathComponent
                group.addTask {
                    await self.loadObject(fileName)
                    await self.updateProgress()
                }
            }
        }
    }
    
    func loadObject(_ fileName: String) async {
        var modelEntity: ModelEntity
        var previewEntity: Entity
        do {
            // Load the USDZ as a ModelEntity.
            try await modelEntity = ModelEntity(named: fileName)
            
            // Load the USDZ as a regular Entity for previews.
            try await previewEntity = Entity(named: fileName)
            previewEntity.name = "Preview of \(modelEntity.name)"
        } catch {
            fatalError("Failed to load model \(fileName)")
        }

        // Set a collision component for the model so the app can detect whether the preview overlaps with existing placed objects.
        do {
            let shape = try await ShapeResource.generateConvex(from: modelEntity.model!.mesh)
            previewEntity.components.set(CollisionComponent(shapes: [shape], isStatic: false,
                                                            filter: CollisionFilter(group: PlaceableObject.previewCollisionGroup, mask: .all)))

            // Ensure the preview only accepts indirect input (for tap gestures).
            let previewInput = InputTargetComponent(allowedInputTypes: [.indirect])
            previewEntity.components[InputTargetComponent.self] = previewInput
        } catch {
            fatalError("Failed to generate shape resource for model \(fileName)")
        }

        let descriptor = ModelDescriptor(fileName: fileName, displayName: modelEntity.displayName)
        placeableObjects.append(PlaceableObject(descriptor: descriptor, renderContent: modelEntity, previewEntity: previewEntity))
    }
}

fileprivate extension ModelEntity {
    var displayName: String? {
        !name.isEmpty ? name.replacingOccurrences(of: "_", with: " ") : nil
    }
}
