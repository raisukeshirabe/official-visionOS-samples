/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Hosts the main game phases for Joyride and Work.
*/

import SwiftUI
import RealityKit

@MainActor
struct ImmersiveView: View {

    @Environment(AppModel.self) private var appModel

    @State private var viewModel = ImmersiveViewModel()

    var body: some View {

        RealityView { content in
            content.add(viewModel.rootEntity)
            content.add(appModel.audioMixer.entity)

            appModel.shipControlParameters.reset()

            // Handle collisions
            _ = content.subscribe(to: CollisionEvents.Began.self, viewModel.handleCollisionBegan(_:))

#if os(visionOS) && !targetEnvironment(simulator)
            HandsShipControlProviderSystem.registerSystem()
            viewModel.rootEntity.addChild(Entity.makeHandTrackingEntities())
#endif
            ShipControlSystem.registerSystem()
            Gravity.register()

#if os(iOS)
            // MARK: On iOS, set up RealityView to use AR world tracking
            await content.setupWorldTracking()
            content.camera = .spatialTracking
#endif
        }
        .task {
            do {
                try await viewModel.loadCollisionAudio()
                try await viewModel.planetsAudio.load()
            } catch {
                print("Could not load resources. Error=\(error).")
            }
        }
        .onChange(of: appModel.gamePhase, initial: true) { old, new in
            Task {
                appModel.isTransitioningBetweenGamePhases = true
                try await viewModel.transitionGamePhase(from: old, to: new)
                appModel.isTransitioningBetweenGamePhases = false

                viewModel.spaceship?.components.set(
                    ShipControlComponent(parameters: appModel.shipControlParameters)
                )
            }
        }
        .onChange(of: appModel.wantsToPresentImmersiveSpace) {
            if appModel.wantsToPresentImmersiveSpace {
                appModel.isPresentingImmersiveSpace = true
            } else {
                Task {
                    viewModel.fadeOutWorkMusic(duration: 2)
                    viewModel.fadeOutJoyRideMusic(duration: 2)
                    viewModel.planetsAudio.fadeOut()
                    try await viewModel.fadeOutSpaceship()
                    appModel.isPresentingImmersiveSpace = false
                }
            }
        }
#if os(visionOS)
        .onChange(of: appModel.surroundings, initial: true) { old, new in
            Task {
                appModel.updateImmersion()
                appModel.isTransitioningBetweenSurroundings = true
                try await viewModel.transitionSurroundings(from: old, to: new)
                appModel.isTransitioningBetweenSurroundings = false
            }
        }
#endif
    }
}
