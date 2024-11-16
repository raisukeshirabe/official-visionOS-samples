/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
View model for the ImmersiveView.
*/

import ARKit
import RealityKit

@MainActor
final class ImmersiveViewModel {

#if os(visionOS)
    let sceneReconstruction = SceneReconstruction()
    let headTrackingSession = ARKitSession()
    let headTrackingProvider = WorldTrackingProvider()
#endif

    let audio = AudioStorage()
    let planetsAudio = PlanetsAudioStorage()
    let spaceshipAudio = SpaceshipAudioStorage()
    let immersiveEnvironment = ImmersiveEnvironmentStorage()

    let rootEntity = Entity()
    var spaceship: ModelEntity?
    var trailer: Entity?
    var astronomicalObjects: Entity?

    static var debounceThreshold = 0.05
    var debounce: [UnorderedPair<Entity>: TimeInterval] = [:]

    var gameLevel = 1

    init() {
        configureRoot()
        configureAmbientMusicSource()
        rootEntity.addChild(immersiveEnvironment.entity)
#if os(visionOS)
        Task {
            try await headTrackingSession.run([headTrackingProvider])
        }
#endif
    }

    func configureRoot() {
        rootEntity.name = "Root"
    }
}
