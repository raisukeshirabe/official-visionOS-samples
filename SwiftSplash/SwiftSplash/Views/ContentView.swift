/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main SwiftUI view.
*/

import SwiftUI
import RealityKit
/// The app's main view.
struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    private let lightGrayTextColor = Color(white: 0.84)
    @State private var countDown: CFAbsoluteTime = -1.0
    @State private var confirmationShown = false
    @State private var isReducedHeight = false
    
    var body: some View {
        @Bindable var appState = appState
        switch appState.phase {
            case .startingUp, .waitingToStart, .loadingAssets, .placingStartPiece, .draggingStartPiece:
                Spacer()
                SplashScreenView()
                    .onAppear {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                            return
                        }
                        
                        windowScene.requestGeometryUpdate(.Vision(resizingRestrictions: UIWindowScene.ResizingRestrictions.none))
                    }
                    .glassBackgroundEffect()
            case .buildingTrack, .rideRunning:
                Spacer()
                NavigationStack(path: $appState.presentedRide) {
                    PieceShelfView()
                        .transition(.opacity)
                        .navigationTitle(Text("Build", comment: "The title of the navigation bar in build mode."))
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationDestination(for: RideDestination.self) { ride in
                            RideControlView()
                                .transition(.opacity)
                                .navigationTitle(Text("Ride", comment: "The title of the navigation bar when running the ride."))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    Button {
                                        appState.isVolumeMuted.toggle()
                                    } label: {
                                        Label {
                                            if appState.isVolumeMuted {
                                                Text("Unmute", comment: "An action to unmute the game's audio.")
                                            } else {
                                                Text("Mute", comment: "An action to mute the game's audio.")
                                            }
                                        } icon: {
                                            if appState.isVolumeMuted {
                                                Image(systemName: "speaker.slash.fill")
                                            } else {
                                                Image(systemName: "speaker.wave.3.fill")
                                            }
                                        }
                                        .animation(.none, value: 0)
                                        .fontWeight(.semibold)
                                        .frame(width: 100)
                                    }
                                }
                                .toolbar(.visible, for: .navigationBar)
                                .toolbarRole(.navigationStack)
                        }
                        .toolbar {
                            ContentToolbar()
                        }
                        .toolbar(.visible, for: .navigationBar)
                        .onChange(of: appState.trackPieceBeingEdited) { _, trackPieceBeingEdited in
                            guard let trackPieceBeingEdited = trackPieceBeingEdited else { return }
                            trackPieceBeingEdited.connectableStateComponent?.isSelected = true
                            appState.updateSelection()
                        }
                }
                .frame(width: 460, height: !isReducedHeight ? 540 : 200)
                
                // If someone closes the main window, dismiss the immersive space. If placing the first piece, ignore it.
                .onChange(of: scenePhase) { _, newPhase in
                    Task { @MainActor in
                        if (newPhase == .background || newPhase == .inactive) && appState.isImmersiveViewShown
                            && appState.phase != .placingStartPiece && appState.phase != .draggingStartPiece {
                            appState.resetBoard()
                            appState.goBackToWaiting()
                            await dismissImmersiveSpace()
                            appState.isImmersiveViewShown = false
                        }
                    }
                }
                .onChange(of: appState.presentedRide) {
                    if appState.presentedRide.isEmpty {
                        withAnimation {
                            // Went back.
                            shouldCancelRide = true
                            appState.resetRideAnimations()
                            appState.addHoverEffectToConnectables()
                            appState.goalPiece?.stopWaterfall()
                            appState.returnToBuildingTrack()
                            appState.isRideRunning = false
                            appState.music = .build
                            appState.updateConnections()
                            appState.updateSelection()
                            appState.goalPiece?.setAllParticleEmittersTo(to: false)
                        }
                    } else {
                        // Play.
                        shouldCancelRide = false
                    }
                    
                    Task {
                        try? await Task.sleep(for: .seconds(0.1))
                        withAnimation(.easeIn(duration: 1.0)) {
                            if appState.presentedRide.isEmpty {
                                isReducedHeight = false
                            } else {
                                isReducedHeight = true
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
