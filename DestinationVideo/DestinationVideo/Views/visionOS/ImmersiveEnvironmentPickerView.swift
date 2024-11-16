/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that adds the custom environments to the immersive environment picker in an undocked video player view controller.
*/

import SwiftUI

/// A view that populates the ImmersiveEnvironmentPicker in an undocked AVPlayerViewController.
struct ImmersiveEnvironmentPickerView: View {
    
    var body: some View {
        StudioButton(state: .dark)
        StudioButton(state: .light)
    }
}

/// A view for the buttons that appear in the environment picker menu.
private struct StudioButton: View {
    @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment

    var state: EnvironmentStateType

    var body: some View {
        Button {
            immersiveEnvironment.requestEnvironmentState(state)
            immersiveEnvironment.loadEnvironment()
        } label: {
            Label {
                Text("Studio", comment: "Show Studio environment")
            } icon: {
                Image(["studio_thumbnail", state.displayName.lowercased()].joined(separator: "_"))
            }
            Text(state.displayName)
        }
    }
}
