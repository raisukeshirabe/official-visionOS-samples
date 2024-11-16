/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Views for selecting robot materials.
*/

import Foundation
import RealityKit
import BOTanistAssets
import SwiftUI
import Spatial

/// A view for selecting the mesh type of a robot part.
struct TypeSelectorView: View {
    @Binding var currentPart: RobotPart
    @Binding var meshSelection: [RobotPart: String]
    @Binding var materialSelection: [RobotPart: RobotMaterial]
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            HStack {
                Text(currentPart.name).bold()
                Spacer()
            }
            HStack {
                ForEach(currentPart.partNames, id: \.self) { partName in
                    Button() {
                        meshSelection[currentPart] = partName
                        appState.setMesh(part: currentPart, name: partName)
                        appState.setMaterial(part: currentPart, material: materialSelection[currentPart] ?? .rainbow)
                    } label: {
                        Image(partName)
                            .resizable()
                            .scaledToFit()
                            .background(meshSelection[currentPart] == partName ? Color.gray: Color.clear, in: Circle())
                    }.padding()
                }
            }.buttonStyle(.plain)
        }
    }
}

/// A view for selecting the face type of a robot part.
struct FaceSelectorView: View {
    
    @Binding var currentFace: RobotFace
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            HStack {
                Text("Eye Shape", comment: "A label for the group of buttons that change the shape of the robot's eyes.").bold()
                Spacer()
            }
            HStack {
                ForEach(RobotFace.allCases) { face in
                    Button() {
                        currentFace = face
                        appState.setFace(face: face)
                    } label: {
                        Image(face.rawValue)
                            .resizable()
                            .scaledToFit()
                            .background(currentFace == face ? Color.gray: Color.clear, in: Circle())
                    }.padding()
                }
            }
        }.buttonStyle(.plain)
    }
}

#Preview(traits: .sampleAppState) {
    @Previewable @State var currentFace = RobotFace.heart
    FaceSelectorView(currentFace: $currentFace)
}

/// A view for selecting the material color of a robot part.
struct MaterialColorSelectView: View {
    @Binding var currentPart: RobotPart
    @Binding var materialSelection: [RobotPart: RobotMaterial]
    @Binding var colorSelection: [RobotPart: Color]
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            HStack {
                Text("Material Color", comment: "A label for the group of buttons that change the robot's color.").bold()
                Spacer()
            }
            HStack {
                ForEach(Array(zip(materialSelection[currentPart]!.colors.indices, materialSelection[currentPart]!.colors)), id: \.0) { index, color in
                    Button() {
                        colorSelection[currentPart] = color
                        appState.setColorIndex(part: currentPart, colorIndex: index)
                    } label: {
                        if colorSelection[currentPart] == color {
                            Circle()
                                .fill(color)
                                .scaledToFit()
                                .padding()
                                .background(Circle().stroke(lineWidth: 15).fill(color))
                                .padding()
                        } else {
                            Circle()
                                .fill(color)
                                .scaledToFit()
                                .padding()
                        }
                        
                    }.padding()
                }
            }.buttonStyle(.plain)
        }
    }
}

/// A view for selecting the material of a robot part.
struct MaterialSelectView: View {
    @Binding var currentPart: RobotPart
    @Binding var materialSelection: [RobotPart: RobotMaterial]
    @Binding var colorSelection: [RobotPart: Color]
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            HStack {
                Text("Material", comment: "A label for the group of buttons that change the material the robot is made of.").bold()
                Spacer()
            }
            HStack {
                ForEach(RobotMaterial.allCases) { matType in
                    Button() {
                        materialSelection[currentPart] = matType
                        colorSelection[currentPart] = matType.colors[0]
                        appState.setMaterial(part: currentPart, material: matType)
                        appState.setColorIndex(part: currentPart, colorIndex: 0)
                    } label: {
                        Image(matType.rawValue)
                            .resizable()
                            .scaledToFit()
                            .background(materialSelection[currentPart] == matType ? Color.gray: Color.clear, in: Circle())
                    }.padding()
                }
            }.buttonStyle(.plain)
        }
    }
}

/// A view for selecting the light color of a robot part.
struct LightColorSelectView: View {
    @Binding var currentPart: RobotPart
    @Binding var lightColorSelection: [RobotPart: RobotLightColor]
    @Environment(AppState.self) private var appState
    
    var body: some View {
        HStack {
            Text("Light Color",
                 comment: "A label for the group of buttons that change the color of the illuminated parts of the robot.").bold()
            Spacer()
        }
        Grid {
            GridRow {
                ForEach(RobotLightColor.allCases[0..<RobotLightColor.allCases.count / 2]) { lightColor in
                    Button() {
                        lightColorSelection[currentPart] = lightColor
                        appState.setLightColor(part: currentPart, lightColor: lightColor)
                    } label: {
                        if lightColorSelection[currentPart] == lightColor {
                            Circle()
                                .fill(lightColor.uiColor)
                                .scaledToFit()
                                .padding()
                                .background(Circle().stroke(lineWidth: 15).fill(lightColor.uiColor))
                                .padding()
                        } else {
                            Circle()
                                .fill(lightColor.uiColor)
                                .scaledToFit()
                                .padding()
                        }
                    }.padding()
                }
            }
            GridRow {
                ForEach(RobotLightColor.allCases[RobotLightColor.allCases.count / 2..<RobotLightColor.allCases.count]) { lightColor in
                    Button() {
                        lightColorSelection[currentPart] = lightColor
                        appState.setLightColor(part: currentPart, lightColor: lightColor)
                    } label: {
                        if lightColorSelection[currentPart] == lightColor {
                            Circle()
                                .fill(lightColor.uiColor)
                                .scaledToFit()
                                .padding()
                                .background(Circle().stroke(lineWidth: 15).fill(lightColor.uiColor))
                                .padding()
                        } else {
                            Circle()
                                .fill(lightColor.uiColor)
                                .scaledToFit()
                                .padding()
                        }
                    }.padding()
                }
            }
        }.buttonStyle(.plain)
    }
}

