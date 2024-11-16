/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that contains the environment for the robot to move around.
*/

import SwiftUI
import RealityKit
import OSLog
import BOTanistAssets
import Combine

/// The view containing the environment for the robot to move around.
struct ExplorationView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openWindow) var openWindow
    
    @State private var cancellables = [EventSubscription]()
    @FocusState var focusable: Bool
    
    #if os(visionOS)
    /// The current viewpoint from which a person using the app is viewing the volume.
    @State private var currentViewpoint: Viewpoint3D = .standard
    #endif
    var body: some View {
        ZStack {
            RealityView { content in
                let updateEvent = content.subscribe(to: SceneEvents.Update.self, { event in
                    let deltaTime = Float(event.deltaTime)
                    appState.robot?.handleMovement(deltaTime: deltaTime)
                })
                let animationStopEvent = content.subscribe(to: AnimationEvents.PlaybackTerminated.self, { event in
                    guard let robot = appState.robot else { return }
                    
                    if robot.plantsFound == appState.totalPlants && !appState.celebrating {
                        for anim in PlantAnimationProvider.shared.currentGrowAnimations.values where anim.isPlaying {
                                return
                        }
                        appState.startCelebration()
                    }
                })
                #if !os(visionOS)
                    if let environment = try? EnvironmentResource(equirectangular: skyImage) {
                        content.environment = .skybox(environment)
                    }
                #endif
                cancellables.append(updateEvent)
                cancellables.append(animationStopEvent)
                if appState.phase == .exploration {
                    content.add(appState.explorationRoot)
                    content.add(appState.explorationCamera)
                }
            } update: { updateContent in
                // Reset the idle timer when the robot moves.
                appState.robot?.idleTimer = 0
                #if os(visionOS)
                if appState.robot?.idleViewpoint != currentViewpoint.squareAzimuth {
                    appState.robot?.idleViewpoint = currentViewpoint.squareAzimuth
                    appState.robot?.hasChangedOrientationSinceLastWave = true
                }
                #endif
            }
            .platformTouchControls(appState: appState)
            .installTouchControls(appState: appState)
        }
        #if os(visionOS)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .inactive && oldPhase == .active {
                appState.exitExploration()
                openWindow(id: "RobotCreation")
            }
        }
        .onVolumeViewpointChange { _, newViewpoint in
            currentViewpoint = newViewpoint
        }
        #endif
    }
}

let skyImageName = "autumn_field_puresky_1k"
var skyImage: CGImage {
    #if os(macOS)
    if let image = NSImage(named: skyImageName) {
        if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            return cgImage
        }
    }
    #else
    if let image = UIImage(named: skyImageName) {
        if let cgImage = image.cgImage {
            return cgImage
        }
    }
    #endif
    
    fatalError("Sky image not found.")
}

#Preview(traits: .sampleAppState) {
    ExplorationView()
}
