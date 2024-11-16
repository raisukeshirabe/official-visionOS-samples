/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays the robot.
*/

import SwiftUI
import RealityKit
import Spatial

/// A view that displays the robot.
struct RobotView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            StartPlantingButtonView()
            #if !os(visionOS)
                .zIndex(1)
            #endif
            
            RealityView { content in
                content.add(appState.creationRoot)
                content.add(appState.robotCamera)
            }
            .simultaneousGesture(DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard appState.phase == .playing else { return }
                    handleDrag(value)
                }
                .onEnded { value in
                    appState.isRotating = false
                })
        }
    }
    
    /// Rotates the robot about the y-axis when a drag gesture targeting the robot occurs.
    func handleDrag(_ value: EntityTargetValue<DragGesture.Value>) {
        let entity = appState.creationRoot
        
        if !appState.isRotating {
            appState.isRotating = true
            appState.robotCreationOrientation = Rotation3D(entity.orientation(relativeTo: nil))
        }
        let yRotation = value.gestureValue.translation.width / 100
        
        let rotationAngle = Angle2D(radians: yRotation)
        let rotation = Rotation3D(angle: rotationAngle, axis: RotationAxis3D.y)
        
        let startOrientation = appState.robotCreationOrientation
        let newOrientation = startOrientation.rotated(by: rotation)
        entity.setOrientation(.init(newOrientation), relativeTo: nil)
    }
}

#Preview(traits: .sampleAppState) {
    RobotView()
}

struct StartPlantingButtonView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) internal var openWindow
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if appState.phase == .playing {
                    Button(action: {
                        appState.phase = .exploration
                        Task { @MainActor in
                            appState.prepareForExploration()
                            #if os(visionOS)
                            openWindow(id: "RobotExploration")
                            #endif
                        }
                    }) {
                        Text("Start Planting", comment: "A label for the button that starts the gameplay.")
                            #if os (macOS)
                            .foregroundStyle(.black)
                            #endif
                    }
                    .padding()
                }
            }
            .padding([.trailing, .top])
            Spacer()
        }
    }
}
