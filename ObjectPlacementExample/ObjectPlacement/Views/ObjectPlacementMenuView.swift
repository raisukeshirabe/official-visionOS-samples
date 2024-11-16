/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The menu for interacting with objects.
*/

import SwiftUI

struct ObjectPlacementMenuView: View {
    let appState: AppState

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var presentConfirmationDialog = false

    var body: some View {
        VStack(spacing: 20) {
            ObjectSelectionView(
                modelDescriptors: appState.modelDescriptors,
                selectedFileName: appState.selectedFileName
            ) { descriptor in
                if let model = appState.placeableObjectsByFileName[descriptor.fileName] {
                    appState.placementManager?.select(model)
                }
            }

            Button("Remove all objects", systemImage: "trash") {
                presentConfirmationDialog = true
            }
            .font(.subheadline)
            .buttonStyle(.borderless)
            .confirmationDialog("Remove all objects?", isPresented: $presentConfirmationDialog) {
                Button("Remove all", role: .destructive) {
                    Task {
                        await appState.placementManager?.removeAllPlacedObjects()
                    }
                }
            }

            Button("Leave", systemImage: "xmark.circle") {
                Task {
                    await dismissImmersiveSpace()
                    appState.didLeaveImmersiveSpace()
                }
            }
            .font(.subheadline)
            .buttonStyle(.borderless)
        }
    }
}

#Preview(windowStyle: .plain) {
    ObjectPlacementMenuView(appState: AppState.previewAppState(selectedIndex: 1))
        .padding(20)
        .frame(width: 400)
        .glassBackgroundEffect()
}
