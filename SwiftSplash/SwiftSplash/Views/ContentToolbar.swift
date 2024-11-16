/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The ContentView view's toolbar.
*/

import SwiftUI

struct ContentToolbar: View {
    @Environment(AppState.self) private var appState
    
    @State private var confirmationShown = false
    
    var body: some View {
        Button(role: .destructive) {
            confirmationShown = true
        } label: {
            Label {
                Text("Delete ride", comment: "An action to delete the ride.")
            } icon: {
                Image(systemName: "trash.fill")
            }
        }
        .accessibilityElement()
        .confirmationDialog(
            Text("Are you sure you want to delete all pieces and start over?", comment: "A warning about a destructive action the player can take."),
            isPresented: $confirmationShown,
            titleVisibility: .visible
        ) {
            Text("Are you sure you want to delete all pieces and start over?",
                 comment: "A warning about a destructive action the player can take.")
            Button(role: .destructive) {
                withAnimation {
                    appState.resetBoard()
                }
            } label: {
                Text("Delete ride", comment: "An action the player can take.")
            }
            Button(role: .cancel) { } label: {
                Text("Continue editing", comment: "An action the player can take.")
            }
        }
        
        Button {
            if appState.trackPieceBeingEdited == nil {
                appState.trackPieceBeingEdited = appState.startPiece
                appState.trackPieceBeingEdited?.connectableStateComponent?.isSelected = true
                appState.showEditAttachment()
            }
            
            appState.updateConnections()
            appState.updateSelection()
            appState.selectAll()
        } label: {
            Label {
                Text("Select All", comment: "An action to select all pieces.")
            } icon: {
                Image(systemName: "plus.square.dashed")
            }
        }
        .accessibilityElement()
        
        Button {
            appState.isVolumeMuted.toggle()
        } label: {
            Label {
                if appState.isVolumeMuted {
                    Text("Unmute", comment: "An action to unmute the game audio.")
                } else {
                    Text("Mute", comment: "An action to mute the game audio.")
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
        .accessibilityElement()
    }
}
