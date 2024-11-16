/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Holds the data that makes up a single robot.
*/

import Foundation
import RealityKit
import SwiftUI
import BOTanistAssets

/// The structure that contains the data that makes up a single robot.
@MainActor
public struct RobotData: Sendable {
    
    /// The selected mesh for each of the parts.
    var meshes = [RobotPart: Entity]()
    
    /// The selected mesh shape for the selected parts.
    var shapes: [RobotPart: Int] {
        var result = [RobotPart: Int]()
        for key in meshes.keys {
            guard let entityNameSuffix = meshes[key]?.name.last else { fatalError("Entity doesn't have expected suffix.") }
            guard let value = Int(String(entityNameSuffix)) else { fatalError("Unable to convert entity suffix to Int.") }
            result[key] = value
        }
        return result
    }
    
    /// The index of the selected mesh shape for retrieving from arrays
    var shapeIndices: [RobotPart: Int] {
        let shapes = shapes
        var result = [RobotPart: Int]()
        for key in shapes.keys {
            result[key] = shapes[key]! - 1
        }
        return result
    }
    
    /// The selected material for each part
    var materials = [RobotPart: RobotMaterial]()
    
    /// The selected material color for each part
    var materialColorIndex = [RobotPart: Int]()
    
    /// The selected light color for each part
    var lightColor = [RobotPart: RobotLightColor]()
    
    /// The selected face
    var face = RobotFace.circle
    
    init() {
        for part in RobotPart.allCases {
            if part == RobotPart(rawValue: "backpack") {
                meshes[part] = RobotProvider.shared.getMesh(forPart: part, index: 0)
            } else {
                meshes[part] = RobotProvider.shared.getMesh(forPart: part, index: 1)
            }
            materials[part] = .plastic
            materialColorIndex[part] = 0
            lightColor[part] = .white
        }
    }
}

/// The different types of robot materials.
public enum RobotMaterial: String, CaseIterable, Codable, Sendable, Identifiable, Equatable {
    case metal
    case rainbow
    case plastic
    case mesh
    
    var entityNames: [String] {
        var ret = [String]()
        RobotPart.allCases.forEach() { part in
            for index in 1...RobotPart.numberOfParts {
                ret.append("\(part.suffix)\(index)")
            }
        }
        return ret
    }
    
    static var randomMaterial: RobotMaterial {
        let index = Int.random(in: 0...3)
        return RobotMaterial.allCases[index]
    }
    
    var sceneName: String {
        return "Materials/M_\(self.rawValue)"
    }
    
    var colors: [Color] {
        guard let colorList = _colors[self] else { fatalError("Error: non-existent fire") }
        return colorList
    }
    
    private var _colors: [RobotMaterial: [Color]] {
        [ .metal: [.metalPink, .metalOrange, .metalGreen, .metalBlue],
          .rainbow: [.beige, .rainbowRed, .rose, .black],
          .plastic: [.plasticBlue, .plasticPink, .plasticOrange, .plasticGreen],
          .mesh: [.meshGray, .meshOrange, .meshYellow, .black]]
    }
    
    public var id: Self { self }
}

public enum BodyType: Int, CaseIterable, Codable, Sendable, Identifiable {
    case bipedal = 1
    case wheeled = 2
    case hovering = 3
    
    public var id: Self { self }
}

/// Defines the various mesh parts that make up a robot.
public enum RobotPart: String, CaseIterable, Codable, Sendable, Identifiable, Equatable {
    case head
    case body
    case backpack
    
    static let numberOfParts = 3
    
    /// The suffix used in Reality Composer Pro to distinguish which part a material or entity relates to.
    var suffix: String {
        switch self {
            case .head:
                return "H"
            case .body:
                return "B"
            case .backpack:
                return "BP"
        }
    }
    
    static func partForMaterialName(name: String) -> RobotPart? {
        if name.dropLast().hasSuffix("BP") {
            return .backpack
        } else if name.dropLast().hasSuffix("B") {
            return .body
        } else if name.dropLast().hasSuffix("H") {
            return .head
        }
        return nil
    }
    
    var sceneNames: [String] {
        var sceneNames = [String]()
        for index in 1...RobotPart.numberOfParts {
            sceneNames.append("scenes/\(self.rawValue)\(index)")
        }
        return sceneNames
    }
    
    var partNames: [String] {
        var partNames = [String]()
        for index in 1...RobotPart.numberOfParts {
            partNames.append("\(self.rawValue)\(index)")
        }
        return partNames
    }
    
    var name: String {
        switch self {
        case .head:
            String(localized: "Head", comment: "A bodypart of the robot.")
        case .body:
            String(localized: "Body", comment: "A bodypart of the robot.")
        case .backpack:
            String(localized: "Backpack", comment: "A bodypart of the robot.")
        }
    }
    
    public var id: Self { self }
}

/// The different light colors.
public enum RobotLightColor: String, CaseIterable, Codable, Sendable, Identifiable, Equatable {
    case red, yellow, green, blue, purple, white, purpleBlue, rainbow
    
    @MainActor
    var uiColor: some ShapeStyle {
        switch self {
        case .red:
            return AnyShapeStyle(Color.red)
        case .yellow:
            return AnyShapeStyle(Color.yellow)
        case .green:
            return AnyShapeStyle(Color.green)
        case .blue:
            return AnyShapeStyle(Color.blue)
        case .purple:
            return AnyShapeStyle(Color.purple)
        case .white:
            return AnyShapeStyle(Color.white)
        case .rainbow:
            return AnyShapeStyle(Color.rainbow)
        case .purpleBlue:
            return AnyShapeStyle(Color.purpleBlue)
        }
    }
    
    static func color(forIndex index: Int) -> RobotLightColor {
        guard 0...allCases.count - 1 ~= index else { fatalError("Requested light color doesn't exist.") }
        return allCases[index]
    }
    
    static func randomColor() -> RobotLightColor {
        let choice = Int.random(in: 0..<allCases.count)
        
        for (index, color) in allCases.enumerated() where index == choice {
                return color
        }
        return .red
    }
    
    var index: Int {
        guard let index = RobotLightColor.allCases.firstIndex(of: self) else { fatalError("Requested face doesn't exist.") }
        return index
    }
    
    nonisolated public var id: Self { self }
}

/// The different robot face patterns.
public enum RobotFace: String, CaseIterable, Codable, Sendable, Identifiable, Equatable {
    case square, circle, heart
    
    static func face(forIndex index: Int) -> RobotFace {
        guard 0...allCases.count - 1 ~= index else { fatalError("Requested face doesn't exist.") }
        return allCases[index]
    }
    
    var index: Int {
        guard let index = RobotFace.allCases.firstIndex(of: self) else { fatalError("Requested face doesn't exist.") }
        return index
    }
    
    static var randomFace: RobotFace {
        return face(forIndex: Int.random(in: 0...allCases.count - 1))
    }
    
    public var id: Self { self }
}

// MARK: - Containers -

/// A sendable type used to transfer entities loaded concurrently back to the calling thread.
public struct RobotPartLoadResult: Sendable, Identifiable {
    var entity: Entity
    var type: RobotPart
    var index: Int
    public var id: String { return type.rawValue }
}

/// A sendable type used to transfer shader graph materials loaded concurrently back to the calling thread.
public struct RobotMaterialResult: Sendable, Identifiable, Hashable, Equatable {
    
    var material: RobotMaterial
    var materials = [RobotPart: [ShaderGraphMaterial]]()
    
    public var id: Int {
        return hashValue
    }
    
    public static func == (lhs: RobotMaterialResult, rhs: RobotMaterialResult) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        for _ in materials.values {
            hasher.combine(materials.values.map { $0.map { $0.name } })
        }
    }
}

