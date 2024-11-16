/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view for controlling the ride while it's running.
*/

import SwiftUI
import RealityKit

struct RideControlView: View {
    @Environment(AppState.self) var appState
    @State var elapsed: Double = 0.0
    @State private var animateIn = true
    @State private var paused = true

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Toggle(isOn: $paused) {
                Label {
                    Text(shouldPauseRide ? "Play" : "Pause", comment: "Actions to control the ride.")
                } icon: {
                    Image(systemName: shouldPauseRide ? "play.fill" : "pause.fill")
                }
                .labelStyle(.iconOnly)
            }
            .toggleStyle(.button)
            .padding(.leading, 17)
            .accessibilityElement()
            .accessibilityLabel(Text(shouldPauseRide ? "Play Ride" : "Pause Ride", comment: "Accessibility label: Actions to control the ride."))
            
            let elapsedTime = min(max(elapsed, 0), appState.rideDuration)
            ProgressView(value: elapsedTime, total: appState.rideDuration)
                .tint(.white)
                .onReceive(timer) { _ in
                    if pauseStartTime == 0 {
                        elapsed = (Date.timeIntervalSinceReferenceDate - appState.rideStartTime)
                    } else {
                        elapsed = (Date.timeIntervalSinceReferenceDate - appState.rideStartTime -
                                   (Date.timeIntervalSinceReferenceDate - pauseStartTime))
                    }
                }
                .accessibilityElement()
                .accessibilityValue(Text("\(String.localizedStringWithFormat("%2.0f", elapsed)) percent complete.",
                                         comment: "Accessibility value: The percentage of the ride already ridden"))
            
            Button {
                shouldCancelRide = true
                Task {
                    // Pause a moment to let the previous ride cancel.
                    try await Task.sleep(for: .seconds(0.1))
                    appState.resetRideAnimations()
                    appState.goalPiece?.stopWaterfall()
                    appState.startRide()
                    appState.music = (shouldPauseRide) ? .silent : .ride
                    appState.addHoverEffectToConnectables()
                }
            } label: {
                Label {
                    Text("Restart Ride", comment: "An action the player can take.")
                } icon: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .labelStyle(.iconOnly)
            }
            .padding(.trailing, 9)
            .accessibilityElement()
            .accessibilityValue(Text("Start the ride over from the beginning.", comment: "Accessibility value: An action the player can take."))
        }
        .opacity(animateIn ? 0.0 : 1.0)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                withAnimation(.easeInOut(duration: 0.7)) {
                    animateIn = false
                }
            }
        }
        .onDisappear {
            animateIn = true
        }
        .onChange(of: paused) {
            shouldPauseRide.toggle()
            
            if !shouldPauseRide {
                appState.rideStartTime += Date.timeIntervalSinceReferenceDate - pauseStartTime
                appState.startPiece?.setRideLights(to: true, speed: 1.0)
                appState.goalPiece?.setRideLights(to: true, speed: 1.0)
                SoundEffectPlayer.shared.resumeAll()
            } else {
                appState.startPiece?.setRideLights(to: true, speed: 0.0)
                appState.goalPiece?.setRideLights(to: true, speed: 0.0)
                SoundEffectPlayer.shared.pauseAll()
            }
            
            appState.music = shouldPauseRide ? .silent : .ride
        }
    }
}

#Preview {
    let appState = AppState()
    appState.startPiece = Entity()
    appState.goalPiece = Entity()
    return RideControlView().environment(appState)
}
