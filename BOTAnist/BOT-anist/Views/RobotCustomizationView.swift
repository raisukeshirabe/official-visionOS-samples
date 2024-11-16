/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays robot configuration options.
*/

import SwiftUI
import RealityKit
import Spatial

/// A view that displays the robot configuration options.
struct RobotCustomizationView: View {
    @Environment(AppState.self) private var appState
    
    /// The currently selected materials for each part.
    @State private var partMaterials: [RobotPart: RobotMaterial] = [
        .body: .plastic,
        .head: .plastic,
        .backpack: .plastic
    ]
    
    /// The currently selected light color for each part.
    @State private var partLights: [RobotPart: RobotLightColor] = [
        .head: .white,
        .body: .white,
        .backpack: .white
    ]
    
    /// The currently selected material color for each part.
    @State private var partColors: [RobotPart: Color] = [
        .head: .plasticBlue,
        .body: .plasticBlue,
        .backpack: .plasticBlue
    ]
    
    /// The name of the currently selected mesh type for each part.
    @State private var partMeshes: [RobotPart: String] = [
        .head: "head2",
        .body: "body2",
        .backpack: "backpack1"
    ]
    
    /// The current robot face.
    @State private var currentFace: RobotFace = .circle
    /// The robot part that a person is modifing.
    @State private var currentRobotPart: RobotPart = .head
    
    private func randomizeRobot() {
        guard let randomFace = RobotFace.allCases.randomElement() else { fatalError("Error choosing random face.") }
        appState.setFace(face: randomFace)
        currentFace = randomFace
        
        for part in RobotPart.allCases {
            guard let randomMaterial = RobotMaterial.allCases.randomElement(),
                  let randomColorIndex = (0..<randomMaterial.colors.count).randomElement(),
                  let randomLight = RobotLightColor.allCases.randomElement(),
                  let randomIndex = (0..<RobotPart.numberOfParts).randomElement() else { fatalError("Error randomizing robot parts.") }
            
            let randomMeshName = "\(part)\(randomIndex + 1)"
            let randomColor = randomMaterial.colors[randomColorIndex]
            
            appState.setMesh(part: part, name: randomMeshName)
            partMeshes[part] = randomMeshName
            
            appState.setMaterial(part: part, material: randomMaterial)
            partMaterials[part] = randomMaterial
            
            appState.setLightColor(part: part, lightColor: randomLight)
            partLights[part] = randomLight
            
            appState.setColorIndex(part: part, colorIndex: randomColorIndex)
            partColors[part] = randomColor
            
            appState.setFace(face: RobotFace.randomFace)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("BOT-anist",
                     comment: "Displays \"BOT-anist\" the title of the app.")
                .font(.system(size: 30))
                .bold()
                Spacer()
                Button {
                    appState.resetSelectedRobot()
                    partMaterials = [ .body: .plastic, .head: .plastic, .backpack: .plastic ]
                    partLights = [ .head: .white, .body: .white, .backpack: .white ]
                    partColors = [ .head: .plasticBlue, .body: .plasticBlue, .backpack: .plasticBlue ]
                    partMeshes = [ .head: "head2", .body: "body2", .backpack: "backpack1" ]
                    currentFace = .circle
                } label: {
                    Label {
                        Text("Reset", comment: "A button title that resets the robot customization to the starting state.")
                    } icon: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                
                Button {
                    randomizeRobot()
                } label: {
                    Label {
                        Text("Randomize", comment: "A button title that randomizes the robot's configuration.")
                    } icon: {
                        Image(systemName: "shuffle")
                    }
                }
            }
            .labelStyle(.iconOnly)
            .padding([.leading, .trailing, .top])
            HStack {
                Spacer()
                Picker(String(localized: "Component", comment: "A component of the robot."), selection: $currentRobotPart) {
                    ForEach(RobotPart.allCases) { partKey in
                        Text(partKey.name)
                            .tag(partKey)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                    .accessibilityLabel(String(localized: "Component Picker",
                                               comment: "A module of the BOT-anist app to specify the robot's components."))
            }
            .padding()
            ScrollViewReader { value in
                ScrollView {
                    TypeSelectorView(currentPart: $currentRobotPart,
                                     meshSelection: $partMeshes,
                                     materialSelection: $partMaterials)
                        .id("topView")
                    if currentRobotPart == .head {
                        FaceSelectorView(currentFace: $currentFace)
                    }
                    MaterialSelectView(currentPart: $currentRobotPart,
                                       materialSelection: $partMaterials,
                                       colorSelection: $partColors)
                    
                    MaterialColorSelectView(currentPart: $currentRobotPart,
                                            materialSelection: $partMaterials,
                                            colorSelection: $partColors)
                    
                    LightColorSelectView(currentPart: $currentRobotPart,
                                         lightColorSelection: $partLights)
                }
                .padding(.horizontal)
                .onChange(of: currentRobotPart) {
                    withAnimation {
                        value.scrollTo("topView", anchor: .top)
                    }
                }
            }
        }
        .padding([.top, .leading, .trailing])
    }
}

#Preview(traits: .sampleAppState) {
    RobotCustomizationView()
}
