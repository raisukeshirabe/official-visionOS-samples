/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main user interface.
*/

import SwiftUI
import ARKit

struct HomeView: View {
    let appState: AppState
    let modelLoader: ModelLoader
    let immersiveSpaceIdentifier: String

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Object Placement")
                    .font(.title)

                InfoLabel(appState: appState)
                    .padding(.horizontal, 30)
                    .frame(width: 400)
                    .fixedSize(horizontal: false, vertical: true)

                Group {
                    if !modelLoader.didFinishLoading {
                        VStack(spacing: 10) {
                            Text("Loading models…")
                            ProgressView(value: modelLoader.progress)
                                .frame(maxWidth: 200)
                        }
                    } else if !appState.immersiveSpaceOpened {
                        Button("Enter") {
                            Task {
                                switch await openImmersiveSpace(id: immersiveSpaceIdentifier) {
                                case .opened:
                                    break
                                case .error:
                                    print("An error occurred when trying to open the immersive space \(immersiveSpaceIdentifier)")
                                case .userCancelled:
                                    print("The user declined opening immersive space \(immersiveSpaceIdentifier)")
                                @unknown default:
                                    break
                                }
                            }
                        }
                        .disabled(!appState.canEnterImmersiveSpace)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.vertical, 24)
            .glassBackgroundEffect()

            if appState.immersiveSpaceOpened {
                ObjectPlacementMenuView(appState: appState)
                    .padding(20)
                    .glassBackgroundEffect()
            }
        }
        .fixedSize()
        .onChange(of: scenePhase, initial: true) {
            print("HomeView scene phase: \(scenePhase)")
            if scenePhase == .active {
                Task {
                    // Check whether authorization has changed when the user brings the app to the foreground.
                    await appState.queryWorldSensingAuthorization()
                }
            } else {
                // Leave the immersive space if this view is no longer active;
                // the controls in this view pair up with the immersive space to drive the placement experience.
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
        .onChange(of: appState.providersStoppedWithError, { _, providersStoppedWithError in
            // Immediately close the immersive space if there was an error.
            if providersStoppedWithError {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
                
                appState.providersStoppedWithError = false
            }
        })
        .task {
            // Request authorization before the user attempts to open the immersive space;
            // this gives the app the opportunity to respond gracefully if authorization isn’t granted.
            if appState.allRequiredProvidersAreSupported {
                await appState.requestWorldSensingAuthorization()
            }
        }
        .task {
            // Monitors changes in authorization. For example, the user may revoke authorization in Settings.
            await appState.monitorSessionEvents()
        }
    }
}

#Preview(windowStyle: .plain) {
    HStack {
        VStack {
            HomeView(appState: AppState.previewAppState(),
                     modelLoader: ModelLoader(progress: 0.5),
                     immersiveSpaceIdentifier: "A")
            HomeView(appState: AppState.previewAppState(),
                     modelLoader: ModelLoader(progress: 1.0),
                     immersiveSpaceIdentifier: "A")
        }
        VStack {
            HomeView(appState: AppState.previewAppState(immersiveSpaceOpened: true),
                     modelLoader: ModelLoader(progress: 1.0),
                     immersiveSpaceIdentifier: "A")
        }
    }
}
