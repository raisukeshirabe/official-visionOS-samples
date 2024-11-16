/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Menu view for switching between different scenes and phases.
*/

import SwiftUI
import RealityKit

struct MenuView: View {

    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @Bindable var appModel: AppModel

    var body: some View {
        VStack {
            if appModel.isPresentingImmersiveSpace {
                Toggle("Audio Mixer", systemImage: "slider.vertical.3", isOn: $appModel.isPresentingAudioMixer)
                    .toggleStyle(.button)
                    .onChange(of: appModel.isPresentingAudioMixer) {
                        if appModel.isPresentingAudioMixer {
                            openWindow(id: "AudioMixer")
                        } else {
                            dismissWindow(id: "AudioMixer")
                        }
                    }
            } else {
                HStack {
                    Toggle("Hangar", isOn: $appModel.isPresentingHangar)
                        .disabled(appModel.isPresentingFlightSchool || appModel.isPresentingImmersiveSpace)

#if os(visionOS) && !targetEnvironment(simulator)
                    Toggle("Flight School", isOn: $appModel.isPresentingFlightSchool)
                        .disabled(appModel.isPresentingImmersiveSpace || appModel.isPresentingHangar)
#endif
                }
                .controlSize(.large)
                .toggleStyle(.button)
            }

            Divider()

            VStack {
                Picker("Game Phase", selection: $appModel.gamePhase) {
                    ForEach(GamePhase.allCases, id: \.self) { phase in
                        Text(phase.displayName)
                    }
                }
                .disabled(appModel.isTransitioningBetweenGamePhases)
                .pickerStyle(.segmented)

                Text(appModel.gamePhase == .joyRide ? joyRideDescription : workDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.bottom, .horizontal], 8)
            }

            Divider()

#if os(visionOS)
            SurroundingsPicker(selection: $appModel.surroundings)
                .disabled(appModel.isTransitioningBetweenSurroundings)
            
            Divider()
#endif

            Toggle(
                appModel.wantsToPresentImmersiveSpace ? "Return" : "Fly",
                isOn: $appModel.wantsToPresentImmersiveSpace
            )
            .font(.largeTitle)
            .toggleStyle(FlyReturnToggleStyle())
            .buttonBorderShape(.roundedRectangle(radius: 36))
            .disabled(flyReturnToggleIsDisabled)
        }
        .padding(.vertical, 10)
        .frame(width: 300)
    }

    var flyReturnToggleIsDisabled: Bool {
        appModel.isPresentingHangar ||
        appModel.isPresentingFlightSchool ||
        appModel.isTransitioningBetweenSurroundings ||
        appModel.isTransitioningBetweenGamePhases ||
        (!appModel.wantsToPresentImmersiveSpace && appModel.isPresentingImmersiveSpace)
    }

    var joyRideDescription: String {
        """
        Simply bask in the sensation of flight.

        No matter how hard you fly into things, you don't have to worry about the spaceship \
        exploding!
        """
    }

    var workDescription: String {
        """
        Deliver cargo from planet to planet.

        Watch out: If you run into too many things hard enough, the spaceship will explode!
        """
    }
}

struct FlyReturnToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .frame(maxWidth: .infinity, idealHeight: 100)
        }
    }
}
