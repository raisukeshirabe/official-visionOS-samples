/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The entry point for the Spaceship app.
*/

import SwiftUI
import RealityKit

@main
struct SpaceshipApp: App {

    @State var appModel = AppModel()

#if os(visionOS)
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some SwiftUI.Scene {
        Group {
            WindowGroup {
                MenuView(appModel: appModel)
                    .fixedSize()
            }
            .windowResizability(.contentSize)

            WindowGroup(id: "Hangar") {
                HangarView()
                    .onDisappear {
                        appModel.isPresentingHangar = false
                    }
                    .fixedSize()
            }
            .windowStyle(.volumetric)

            WindowGroup(id: "AudioMixer") {
                AudioMixerView(mixer: appModel.audioMixer)
                    .onDisappear {
                        appModel.isPresentingAudioMixer = false
                    }
                    .frame(width: 400)
            }
            .windowResizability(.contentSize)

#if targetEnvironment(simulator)
            WindowGroup(id: "ShipControl") {
                SimulatorShipControlView(controlParameters: appModel.shipControlParameters)
            }
            .windowResizability(.contentSize)
#endif

            ImmersiveSpace(id: "FlightSchool") {
                FlightSchoolView()
            }
            .immersionStyle(selection: .constant(.mixed), in: .mixed)

            ImmersiveSpace(id: "ImmersiveSpace") {
                ImmersiveView()
                    .environment(appModel)
            }
            .immersionStyle(selection: $appModel.immersionStyle, in: .mixed, .progressive)
        }
        .onChange(of: appModel.wantsToPresentImmersiveSpace) {
            appModel.isPresentingImmersiveSpace = true
        }
        .onChange(of: appModel.isPresentingImmersiveSpace) {
            Task {
                if appModel.isPresentingImmersiveSpace {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        appModel.isPresentingImmersiveSpace = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        appModel.isPresentingImmersiveSpace = false
                    }

#if targetEnvironment(simulator)
                    openWindow(id: "ShipControl")
#endif
                } else {
                    await dismissImmersiveSpace()

#if targetEnvironment(simulator)
                    dismissWindow(id: "ShipControl")
#endif
                }
            }
        }
        .onChange(of: appModel.isPresentingHangar) {
            if appModel.isPresentingHangar {
                openWindow(id: "Hangar")
            } else {
                dismissWindow(id: "Hangar")
            }
        }
        .onChange(of: appModel.isPresentingFlightSchool) {
            Task {
                if appModel.isPresentingFlightSchool {
                    await openImmersiveSpace(id: "FlightSchool")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
#endif

#if os(iOS)

    @State var isMenuExpanded: Bool = true

    var body: some SwiftUI.Scene {
        Group {
            WindowGroup {
                ZStack {
                    if appModel.isPresentingImmersiveSpace {
                        ZStack {
                            ImmersiveView()
                                .environment(appModel)

                            MultiTouchControlView(controlParameters: appModel.shipControlParameters)
                        }
                    }

                    if appModel.isPresentingHangar {
                        HangarView()
                    }

                    if appModel.isPresentingAudioMixer {
                        AudioMixerView(mixer: appModel.audioMixer)
                            .frame(width: 200)
                            .padding(20)
                            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .anchorToTopRight()
                    }

                    DisclosureGroup("Menu", isExpanded: $isMenuExpanded) {
                        MenuView(appModel: appModel)
                    }
                    .frame(width: isMenuExpanded ? 300 : 80)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .anchorToTopLeft()
                }
                .ignoresSafeArea()
            }
            .onChange(of: appModel.wantsToPresentImmersiveSpace) {
                appModel.isPresentingImmersiveSpace = true
            }
        }
    }
#endif
}
