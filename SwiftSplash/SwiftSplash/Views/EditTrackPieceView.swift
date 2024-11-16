/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view used as an attachment to edit the selected piece or pieces.
*/
import SwiftSplashTrackPieces
import SwiftUI
struct EditTrackPieceView: View {
    @Environment(AppState.self) var appState
    @State private var isSelecting = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Button {
                    appState.selectConnectedPieces()
                } label: {
                    Text("\(Image(systemName: "plus.square.dashed")) Select Attached",
                         comment: "An action the player can take. Specifier is replaced by a + image.")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                }
                .padding(.leading, 20)
                .accessibilityElement()
                .accessibilityLabel(Text("Select all ride pieces that connect back to this piece.",
                                         comment: "For accessibility: An action to select certain ride pieces."))
                
                Spacer()
                
                Button(role: .destructive) {
                    if let goalPiece = appState.goalPiece {
                        if appState.trackPieceBeingEdited == goalPiece ||
                            appState.additionalSelectedTrackPieces.contains(goalPiece) {
                            goalPiece.removeFromParent()
                        }
                    }
                    appState.deleteSelectedPieces()
                    
                } label: {
                    Label {
                        Text("Delete", comment: "An action the user can take on the selected ride piece or pieces.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                    .labelStyle(.iconOnly)
                }
                .disabled(appState.trackPieceBeingEdited == appState.startPiece)
                .accessibilityElement()
                .accessibilityLabel(Text("Delete all selected ride pieces.",
                                         comment: "For accessibility: An action the user can take on the selected ride piece or pieces."))
                Spacer()
                
                Button {
                    appState.clearSelection(keepPrimary: false)
                } label: {
                    Label {
                        Text("Dismiss", comment: "An action to clear the selection and dismiss this wondow.")
                    } icon: {
                        Image(systemName: "checkmark")
                    }
                    .labelStyle(.iconOnly)
                }
                .padding(.trailing, 5)
                .accessibilityElement()
                .accessibilityLabel(Text("Clear the selection and dismiss this window.",
                                         comment: "For accessibility: An action to clear the selection and dismiss this wondow."))
                .padding(.trailing, 20)
            }
            .padding(.vertical)
            .frame(maxWidth: 480)
            .background(.regularMaterial)
            
            HStack {
                Button {
                    appState.setMaterialForAllSelected(.metal)
                } label: {
                    VStack {
                        Image(decorative: "metalPreview")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Metal", comment: "A choice for the player to make the selected piece or pieces to have a metal material.")
                    }
                    .padding(.vertical, 10)
                }
                .accessibilityElement()
                .accessibilityLabel(Text("Change all selected pieces to use a metal material.",
                                         comment: "The accessibility label for picking the metal material for the selected piece."))
                
                Button {
                    appState.setMaterialForAllSelected(.wood)
                } label: {
                    VStack {
                        Image(decorative: "woodPreview")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Wood", comment: "A choice for the player to make the selected piece or pieces to have a wood material.")
                    }
                    .padding(.vertical, 10)
                }
                .accessibilityElement()
                .accessibilityLabel(Text("Change all selected pieces to use a wood material.",
                                         comment: "The accessibility label for picking the wood material for the selected piece."))
                
                Button {
                    appState.setMaterialForAllSelected(.plastic)
                } label: {
                    VStack {
                        Image(decorative: "plasticPreview")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Plastic", comment: "A choice for the player to make the selected piece or pieces to have a plastic material.")
                    }
                    .padding(.vertical, 10)
                }
                .accessibilityElement()
                .accessibilityLabel(Text("Change all selected pieces to use a plastic material.",
                                         comment: "The accessibility label for picking the plastic material for the selected piece."))
            }
            .buttonBorderShape(.roundedRectangle(radius: 15))
            .buttonStyle(.borderless)
            .padding()
        }
        .glassBackgroundEffect()
    }
}
#Preview {
    VStack {
        Spacer()
        EditTrackPieceView()
            .environment(AppState())
    }
}
