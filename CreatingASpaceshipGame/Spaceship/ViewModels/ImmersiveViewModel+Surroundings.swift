/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Surroundings related extensions for the ImmersiveViewModel.
*/

import SwiftUI
import RealityKit
import Studio

extension ImmersiveViewModel {

    func transitionSurroundings(from previous: Surroundings, to current: Surroundings) async throws {
        #if os(visionOS)
        if current == .passthrough {
            try await sceneReconstruction.start()
            rootEntity.addChild(sceneReconstruction.entity)
        } else {
            sceneReconstruction.entity.removeFromParent()
            sceneReconstruction.stop()
        }
        #endif

        switch (previous, current) {
            case (.passthrough, .passthrough):
                break
            case (.passthrough, .studio), (.studio, .studio), (.deepSpace, .studio):
                try await immersiveEnvironment.enterStudio()
            case (.passthrough, .outerSpace), (.outerSpace, .outerSpace), (.deepSpace, .outerSpace):
                try await immersiveEnvironment.enterOuterSpace()
            case (.passthrough, .deepSpace):
                break
            case (.studio, .passthrough), (.studio, .deepSpace):
                try await immersiveEnvironment.exitStudio()
            case (.studio, .outerSpace):
                try await immersiveEnvironment.enterOuterSpace()
                try await immersiveEnvironment.exitStudio()
            case (.outerSpace, .passthrough), (.outerSpace, .deepSpace):
                try await immersiveEnvironment.exitOuterSpace()
            case (.outerSpace, .studio):
                try await immersiveEnvironment.enterStudio()
                try await immersiveEnvironment.exitOuterSpace()
            case (.deepSpace, .deepSpace), (.deepSpace, .passthrough):
                break
        }
    }
}

@MainActor
final class ImmersiveEnvironmentStorage {

    let entity = Entity()

    private var studio: Entity?
    private var outerSpace: Entity?

    func loadStudio() async throws {

        guard studio == nil else { return }

        let studio = try await Entity(named: "Studio", in: studioBundle)
        let collisions = try await Entity(named: "Studio_Collision")
        attachAudioMaterialsToStudioCollisionMesh(collisions)
        studio.addChild(collisions)

        let reverbEntity = Entity()
        reverbEntity.components.set(ReverbComponent(reverb: .preset(.veryLargeRoom)))
        studio.addChild(reverbEntity)

        self.studio = studio
    }

    func loadOuterSpace() async throws {

        guard outerSpace == nil else { return }

        let material = try await Entity.makeStarFieldMaterial()
        let outerSpace = Entity()
        outerSpace.components.set(
            ModelComponent(
                mesh: .generateSphere(radius: 100),
                materials: [material]
            )
        )
        // Point texture image points inward at the viewer.
        outerSpace.scale *= [-1, 1, 1]

        let reverbEntity = Entity()
        reverbEntity.components.set(ReverbComponent(reverb: .anechoic))
        outerSpace.addChild(reverbEntity)

        if let url = Bundle.main.url(forResource: "Starfield", withExtension: "jpg") {
            let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
            let ibl = try! await EnvironmentResource(equirectangular: image)
            let probe = VirtualEnvironmentProbeComponent.Probe(environment: ibl, intensityExponent: 3)
            let probeComponent = VirtualEnvironmentProbeComponent(source: .single(probe))
            
            outerSpace.components.set(probeComponent)
        }

        self.outerSpace = outerSpace
    }

    func enterStudio() async throws {

        if studio == nil {
            try await loadStudio()
        }

        guard let studio else {
            fatalError()
        }

        entity.addChild(studio)
        studio.fadeOpacity(to: 1, duration: 2)
        try await Task.sleep(for: .seconds(2))
    }

    func exitStudio() async throws {
        guard let studio else { return }
        studio.fadeOpacity(to: 0, duration: 2)
        try await Task.sleep(for: .seconds(2))
        studio.removeFromParent()
    }

    func enterOuterSpace() async throws {

        if outerSpace == nil {
            try await loadOuterSpace()
        }

        guard let outerSpace else {
            fatalError()
        }
        entity.addChild(outerSpace)
        outerSpace.fadeOpacity(to: 1, duration: 2)
        try await Task.sleep(for: .seconds(2))
    }

    func exitOuterSpace() async throws {
        guard let outerSpace else { return }
        outerSpace.fadeOpacity(to: 0, duration: 2)
        try await Task.sleep(for: .seconds(2))
        outerSpace.removeFromParent()
    }

    private func attachAudioMaterialsToStudioCollisionMesh(_ entity: Entity) {
        // Map from ideal materials to our available audio materials
        let materialByName: [(String, AudioMaterial)] = [
            ("Canvas", .fabric),
            ("Concrete", .concrete),
            ("Glass", .glass),
            ("Metal", .metal),
            ("DryWall", .wood),
            ("Wood", .wood)
        ]
        // The collision mesh has an entity for which all child entities share the same material
        for (name, material) in materialByName {
            let materialEntity = entity.findEntity(named: name)!
            materialEntity.children.forEach {
                $0.components.set(AudioMaterialComponent(material: material))

                // When we spawn new planets during the Work game phase, we only want to spawn them
                // within the available space. In mixed immersion, this is your scene reconstruction
                // mesh. For the Studio, use the scene understanding collision group to ensure that
                // we only spawn new planets inside the Studio. Otherwise we could undesirably
                // spawn planets below the floor, making them unaccessible and blocking game play.
                $0.components[CollisionComponent.self]!.filter = .init(
                    group: .sceneUnderstanding,
                    mask: .all
                )
            }
        }
    }
}

enum Surroundings: String, CaseIterable {

    case passthrough
    case studio
    case outerSpace
    case deepSpace

    var displayName: String {
        switch self {
        case .passthrough:
            "Passthrough"
        case .studio:
            "Studio"
        case .outerSpace:
            "Outer Space"
        case .deepSpace:
            "Deep Space"
        }
    }

#if os(visionOS)
    var immersionStyle: ImmersionStyle {
        switch self {
        case .passthrough:
            .mixed
        case .studio, .outerSpace, .deepSpace:
            .progressive(0.2...1, initialAmount: 1)
        }
    }
#endif
}
