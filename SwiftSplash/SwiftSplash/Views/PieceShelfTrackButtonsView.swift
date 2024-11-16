/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view holding buttons that add new slide pieces to the ride.
*/

import SwiftUI

struct PieceShelfTrackButtonsView: View {
    @Environment(AppState.self) var appState
    @State private var endPieceIsInRealityView = false
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                ImageButton(
                    title: String(localized: "Simple Ramp", comment: "The name of a ride piece."),
                    imageName: appState.simpleRampImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide1, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add straight slide piece.", comment: "Accessibility label: The action of adding a ride piece."))
                
                ImageButton(
                    title: String(localized: "Right Turn", comment: "The name of a ride piece."),
                    imageName: appState.rightTurnImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide3, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add right turn piece.", comment: "Accessibility label: The action of adding a ride piece."))
                
                ImageButton(
                    title: String(localized: "Left Turn", comment: "The name of a ride piece."),
                    imageName: appState.leftTurnImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide4, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add left turn piece.", comment: "Accessibility label: The action of adding a ride piece."))
            }
            GridRow {
                ImageButton(
                    title: String(localized: "Slide", comment: "The name of a ride piece."),
                    imageName: appState.slideImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide2, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add straight slide piece.", comment: "Accessibility label: The action of adding a ride piece."))
                
                ImageButton(
                    title: String(localized: "Spiral", comment: "The name of a ride piece."),
                    imageName: appState.spiralImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide5, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add spiral slide piece.", comment: "Accessibility label: The action of adding a ride piece."))
                ImageButton(
                    title: String(localized: "Finish Line", comment: "The name of a ride piece."),
                    imageName: appState.goalImageNamne,
                    buttonAction: { button in
                        appState.addGoalPiece()
                        appState.hideMarkerPiece()
                        appState.clearSelection()
                        appState.updateConnections()
                    }
                )
                .disabled(endPieceIsInRealityView)
                .accessibilityElement()
                .accessibilityLabel(Text("Add finish line.", comment: "Accessibility label: The action of adding a ride piece."))
                .onAppear {
                    Task {
                        while true {
                            try? await Task.sleep(for: .milliseconds(200))
                            endPieceIsInRealityView = appState.goalPiece?.parent != nil
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 25)

    }
}

#Preview {
    PieceShelfTrackButtonsView()
        .environment(AppState())
}
