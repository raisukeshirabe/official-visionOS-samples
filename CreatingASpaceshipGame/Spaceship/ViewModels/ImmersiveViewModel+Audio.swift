/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Audio related extensions for the ImmersiveViewModel.
*/

import QuartzCore
import RealityKit
import CoreAudio
import Algorithms

extension ImmersiveViewModel {
    
    func playAudio(for collision: CollisionEvents.Began) {

        // If the collision event's impulse is too weak, don't spend resources to emit sound.
        if collision.impulse < 1e-3 {
            return
        }

        // Determine the appropriate relative loudness for the collision
        let relativeDecibels = relativeLoudness(of: collision)

        // If the sound is going to be very quiet, don't use up resources trying to play it.
        if relativeDecibels < -30 {
            return
        }

        let entities = UnorderedPair(collision.entityA, collision.entityB)

        // At least one of the entities must have a known audio material.
        guard entities.either(where: { $0.components.has(AudioMaterialComponent.self) }) else {
            return
        }

        // Determine the best entity from which to play collision audio
        let playbackEntity = entityForAudioPlaybackInCollision(between: entities)

        // If both of the entities have known audio materials, play the appropriate collision sound
        // at the appropriate level on one of the entities.
        if let materials = entities.audioMaterials {
            // If both entities have known audio materials, play them
            return playAudio(for: materials, on: playbackEntity, at: relativeDecibels)
        }
        
        // If one of the entities has an array of audio materials (e.g., the scene reconstruction
        // mesh on visionOS in mixed immersion), look up the audio material associated with the
        // mesh face involved in the collision.
        if
            let sceneReconstruction = entities.first(where: { $0.components.has(AudioMaterialLookupComponent.self) }),
            let dynamicObject = entities.other(than: sceneReconstruction),
            let audioMaterial = dynamicObject.components[AudioMaterialComponent.self]?.material {

            // Determine the direction in which to cast the ray based on the impulse direction
            // reported by the collision event. Depending on the ordering of the entities in the
            // collision event, we may need to invert the direction to ensure that the ray is always
            // cast from the dynamically-moving object toward the static scene mesh.
            let sign: Float = collision.entityA == dynamicObject ? -1 : 1
            let direction = collision.impulseDirection * sign

            // If one of the entities is the scene reconstruction mesh, determine the face of the
            // mesh impacted by the collision, and lookup the audio material for the mesh face.
            guard let face = sceneMeshFace(collidedWith: dynamicObject, in: direction) else {
                print("❌ Ray cast did not intersect with scene reconstruction mesh.")
                return
            }
            
            guard let lookedUpMaterial = sceneReconstruction.audioMaterial(at: face) else {
                print("❌ Could not determine audio material for scene reconstruction mesh face \(face)")
                return
            }

            let materials = UnorderedPair(audioMaterial, lookedUpMaterial)
            playAudio(for: materials, on: playbackEntity, at: relativeDecibels)
        }
    }
    
    func entityForAudioPlaybackInCollision(between entities: UnorderedPair<Entity>) -> Entity {

        // If one of the entities involed in the collision is the scene reconstruction mesh, play
        // the audio from the dynamic object colliding with it. The origin of the scene
        // reconstruction mesh entity is usually very distant from the point of collision, whereas
        // the dynamic object is most likely more compact.
        if let sceneReconstruction = entities.first(where: { $0.components.has(AudioMaterialLookupComponent.self) }) {
            return entities.other(than: sceneReconstruction)!
        }

        // If one of the entities is static, it is more likely to be a large architectural entity
        // (e.g., the floor in the Studio), whose origin is distant from the point of collision.
        if let staticBody = entities.first(where: { $0.components[PhysicsBodyComponent.self]?.mode == .static }) {
            return entities.other(than: staticBody)!
        }

        // If the current case is not handled above, simply return the first entity.
        return entities.itemA
    }

    func sceneMeshFace(collidedWith dynamicObject: Entity, in rayDirection: SIMD3<Float>) -> Int? {

        // Cast ray from entity.
        let rayOrigin = dynamicObject.position(relativeTo: nil)
        let rayLength: Float = 0.5

        guard let scene = dynamicObject.scene else {
            return nil
        }

        let rayCastResults = scene.raycast(
            origin: rayOrigin,
            direction: rayDirection,
            length: rayLength,
            query: .nearest,
            mask: .sceneUnderstanding
        )

        return rayCastResults.first?.triangleHit?.faceIndex
    }

    func relativeLoudness(of collision: CollisionEvents.Began) -> Audio.Decibel {
        let entities = UnorderedPair(collision.entityA, collision.entityB)
        let velocities = entities.map {
            $0.components[PhysicsMotionComponent.self]?.linearVelocity
        }
        // A collision with a combined magnitude of 50cm/s is anchored to 0dBFS.
        let referenceVelocity: Float = 0.5
        let velocityA = velocities.itemA ?? .zero
        let velocityB = velocities.itemB ?? .zero
        let combined = velocityA - velocityB
        let projected = simd_project(combined, collision.impulseDirection)
        let relativeVelocity = simd_length(projected) / referenceVelocity
        return decibels(amplitude: Double(relativeVelocity))
    }

    func playAudio(for materials: UnorderedPair<AudioMaterial>, on entity: Entity, at gain: Audio.Decibel) {

        let resolvedMaterials: UnorderedPair<AudioMaterial>
        switch materials {
        case .init(.rock, .wood):
            resolvedMaterials = .init(.plastic, .rock)
        case .init(.rock, .concrete):
            resolvedMaterials = .init(.rock, .rock)
        case .init(.rock, .fabric):
            resolvedMaterials = .init(.plastic, .rock)
        case .init(.plastic, .plastic):
            resolvedMaterials = .init(.plastic, .glass)
        case .init(.glass, .rock):
            resolvedMaterials = .init(.plastic, .rock)
        default:
            resolvedMaterials = materials
        }

        guard let audioFileGroupResource = audio.collisions[resolvedMaterials] else {
            print("❌ No audio file group resource for collision between \(resolvedMaterials).")
            return
        }

        let controller = entity.playAudio(audioFileGroupResource)
        controller.gain = gain
    }

    func playJoyRideMusic() async throws {
        if let joyRideMusicController = audio.joyRideMusicController {
            joyRideMusicController.play()
            joyRideMusicController.fade(to: .zero, duration: 4)
        } else {
            let resource = try await AudioFileResource(named: "JoyRideMusic", configuration: .music)
            let controller = audio.ambientMusicEntity.prepareAudio(resource)
            controller.gain = -.infinity
            controller.fade(to: .zero, duration: 4)
            controller.play()
            audio.joyRideMusicController = controller
        }

        fadeOutWorkMusic(duration: 2)
    }

    func playWorkMusic() async throws {
        if let workMusicController = audio.workMusicController {
            workMusicController.play()
            workMusicController.fade(to: .zero, duration: 4)
        } else {
            let resource = try await AudioFileResource(named: "WorkMusic", configuration: .music)
            let controller = audio.ambientMusicEntity.prepareAudio(resource)
            controller.gain = -.infinity
            controller.fade(to: .zero, duration: 4)
            controller.play()
            audio.workMusicController = controller
        }

        fadeOutJoyRideMusic(duration: 2)
    }

    func fadeOutJoyRideMusic(duration: TimeInterval) {
        guard let joyRideMusicController = audio.joyRideMusicController else { return }
        joyRideMusicController.fade(to: -.infinity, duration: duration)
    }

    func fadeOutWorkMusic(duration: TimeInterval) {
        guard let workMusicController = audio.workMusicController else { return }
        workMusicController.fade(to: -.infinity, duration: 2)
    }

    func playSpaceshipExplosionAudio() {

        guard let spaceship, let shipDestructFileGroup = audio.shipDestructFileGroup else { return }

        let explosionAudioEntity = Entity()
        explosionAudioEntity.setPosition(spaceship.position, relativeTo: rootEntity)
        rootEntity.addChild(explosionAudioEntity)

        let controller = explosionAudioEntity.playAudio(shipDestructFileGroup)
        controller.completionHandler = {
            controller.entity?.removeFromParent()
        }
    }

    func configureAmbientMusicSource() {
        audio.ambientMusicEntity.components.set(AmbientAudioComponent())
        rootEntity.addChild(audio.ambientMusicEntity)
    }

    func loadCollisionAudio() async throws {

        // Determine all of the URLs in our bundle which are audio files
        let audioURLs = Bundle.main.urls(forResourcesWithExtension: "aiff", subdirectory: nil) ?? []

        // Organize all audio materials into pairs
        let pairs = AudioMaterial.allCases.combinations(ofCount: 2).map { ($0[0], $0[1]) }
        let doubles = AudioMaterial.allCases.map { ($0, $0) }

        audio.collisions = try await withThrowingTaskGroup(
            of: (UnorderedPair<AudioMaterial>, AudioFileGroupResource?).self
        ) { taskGroup in

            for pair in pairs + doubles {
                taskGroup.addTask {
                    let materials = UnorderedPair(pair.0, pair.1)
                    return try await (
                        materials, self.audioFileGroup(for: materials, in: audioURLs)
                    )
                }
            }

            var result: [UnorderedPair<AudioMaterial>: AudioFileGroupResource] = [:]
            for try await mapping in taskGroup {
                let (materials, audioFileGroup) = mapping
                result[materials] = audioFileGroup
            }
            return result
        }

        try await loadShipExplosionAudio()
    }

    func audioFileGroup(
        for materials: UnorderedPair<AudioMaterial>,
        in urls: [URL]
    ) async throws -> AudioFileGroupResource? {
        let foundURLs = urls.filter {
            $0.lastPathComponent.contains(materials.itemA.description) &&
            $0.lastPathComponent.contains(materials.itemB.description)
        }

        if foundURLs.isEmpty {
            return nil
        }

        return try await AudioFileGroupResource.fromURLs(foundURLs, configuration: .collision)
    }

    func loadShipExplosionAudio() async throws {

        let urls = (Bundle.main.urls(forResourcesWithExtension: "aiff", subdirectory: nil) ?? [])
            .filter { $0.lastPathComponent.contains("ShipDestruct") }

        let resource = try await AudioFileGroupResource.fromURLs(urls, configuration: .collision)
        audio.shipDestructFileGroup = resource
    }
}

extension AudioFileGroupResource {
    static func fromURLs(
        _ urls: [URL],
        configuration: AudioFileResource.Configuration
    ) async throws -> AudioFileGroupResource {
        try await withThrowingTaskGroup(
            of: AudioFileResource.self,
            returning: AudioFileGroupResource.self
        ) { taskGroup in

            for url in urls {
                taskGroup.addTask {
                    try await AudioFileResource(contentsOf: url, configuration: .collision)
                }
            }

            var files: [AudioFileResource] = []
            for try await file in taskGroup {
                files.append(file)
            }

            return try AudioFileGroupResource(files)
        }
    }
}

extension AudioFileResource.Configuration {
    static let collision = AudioFileResource.Configuration(
        calibration: .absolute(dBSPL: 85),
        mixGroupName: MixGroup.collisions.rawValue
    )
}

extension Entity {

    func audioMaterial(at face: Int) -> AudioMaterial? {

        guard let classifications = components[AudioMaterialLookupComponent.self] else {
            print("❌ Unable to determine audio material from entity without mesh classification.")
            return nil
        }

        let audioMaterials = classifications.audioMaterialPerFace

        guard audioMaterials.indices.contains(face) else {
            print("❌ Provided face not available in scene reconstruction mesh.")
            return nil
        }

        return audioMaterials[face]
    }
}

extension UnorderedPair where T == Entity {

    // Returns the pair of audio materials for these entities, if they both exist.
    var audioMaterials: UnorderedPair<AudioMaterial>? {
        guard
            let materialA = itemA.components[AudioMaterialComponent.self]?.material,
            let materialB = itemB.components[AudioMaterialComponent.self]?.material
        else {
            return nil
        }
        return UnorderedPair<AudioMaterial>(materialA, materialB)
    }
}

final class PlanetsAudioStorage {
    var controllers: [AudioPlaybackController] = []

    var resourceByGameLevel: [Int: AudioFileResource] = [:]

    func load() async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for gameLevel in 1...7 {
                resourceByGameLevel[gameLevel] = try await AudioFileResource(
                    named: "PlanetTone_\(gameLevel)",
                    configuration: .init(
                        shouldLoop: true,
                        mixGroupName: MixGroup.planets.rawValue
                    )
                )
            }
        }
    }

    func fadeOut() {
        for controller in controllers {
            controller.fade(to: -.infinity, duration: 2)
        }
    }
}

final class AudioStorage {
    var ambientMusicEntity = Entity()
    var joyRideMusicController: AudioPlaybackController?
    var workMusicController: AudioPlaybackController?
    var collisions: [UnorderedPair<AudioMaterial>: AudioFileGroupResource] = [:]
    var shipDestructFileGroup: AudioFileGroupResource?
}

extension AudioFileResource.Configuration {
    static let music = AudioFileResource.Configuration(
        loadingStrategy: .stream,
        shouldLoop: true,
        mixGroupName: MixGroup.music.rawValue
    )
}
