/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main view.
*/

import SwiftUI
import RealityKit

/// The app's main view.
struct MainView: View {
    /// A Boolean value that indicates whether a person can
    /// press the impulse button.
    @State var pushButtonDisabled = false

    /// The settings for the app's pendulum setup.
    let pendulumSettings = PendulumSettings()

    /// An array that contains all the pendulums that are in
    /// the RealityKit scene.
    @State var pendulums: [Entity] = []
    
    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            RealityView { content in
                guard let pendulumScene = try? buildPendulumScene(
                    content: content
                ) else {
                    fatalError("Could not build pendulum scene.")
                }

                #if !os(visionOS)
                content.cameraTarget = pendulumScene
                #endif
            }
            #if os(macOS) || os(iOS) && targetEnvironment(simulator)
            .padding(.bottom, 10)
            .realityViewCameraControls(CameraControls.orbit)
            #endif
            VStack {
                Spacer()
                impulseButton
            }.padding()
        }
    }
    
    /// A button that applies an impulse to the first
    /// ball entity when a person presses it.
    var impulseButton: some View {
        Button(
            action: impulseButtonAction,
            label: {
                Text("Push ball").padding()
                    #if os(macOS)
                    .background(.blue).clipShape(.buttonBorder)
                    #endif
            }
        ).disabled(pushButtonDisabled)
    }
    
    /// Performs an impulse to the first pendulum's ball.
    func impulseButtonAction() {
        // Disable button, to avoid rapid pressing.
        pushButtonDisabled = true
        // Find the first pendulum's ball.
        guard let firstBall = pendulums.first!
            .findEntity(named: "ball")
        else { return }
        // Push the first pendulum's ball.
        try? pushEntity(firstBall)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Re-enable button.
            pushButtonDisabled = false
        }
    }
}

#Preview {
    MainView()
}
