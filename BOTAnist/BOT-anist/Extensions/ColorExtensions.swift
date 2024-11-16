/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension on Colors that adds custom colors and gradients.
*/

import Foundation
import RealityKit
import SwiftUI

public extension Color {
    
    /// Generates a random color.
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    @MainActor
    static var purpleBlue: AngularGradient {
        return AngularGradient(colors: [.red, .orange, .yellow, .green, .cyan, .purple], center: .center)
    }
    
    @MainActor
    static var rainbow: AngularGradient {
        return AngularGradient(colors: [.pink, .purple, .blue, .cyan], center: .center)
    }
    
    static var rose: Color {
        return Color(red: 244 / 255, green: 201 / 255, blue: 201 / 255)
    }
    
    static var beige: Color {
        return Color(red: 224 / 255, green: 211 / 255, blue: 180 / 255)
    }
    
    static var ringBlue: Color {
        return Color(red: 159 / 255, green: 255 / 255, blue: 255 / 255)
    }
    
    static var meshOrange: Color {
        return Color(red: 206 / 255, green: 78 / 255, blue: 52 / 255)
    }
    static var meshYellow: Color {
        return Color(red: 245 / 255, green: 181 / 255, blue: 58 / 255)
    }
    static var meshGray: Color {
        return Color(red: 199 / 255, green: 199 / 255, blue: 204 / 255)
    }
    static var metalPink: Color {
        return Color(red: 226 / 255, green: 95 / 255, blue: 151 / 255)
    }
    static var metalOrange: Color {
        return Color(red: 227 / 255, green: 138 / 255, blue: 29 / 255)
    }
    static var metalGreen: Color {
        return Color(red: 150 / 255, green: 194 / 255, blue: 70 / 255)
    }
    static var metalBlue: Color {
        return Color(red: 92 / 255, green: 140 / 255, blue: 199 / 255)
    }
    static var plasticPink: Color {
        return Color(red: 233 / 255, green: 73 / 255, blue: 127 / 255)
    }
    static var plasticOrange: Color {
        return Color(red: 247 / 255, green: 150 / 255, blue: 31 / 255)
    }
    static var plasticBlue: Color {
        return Color(red: 59 / 255, green: 152 / 255, blue: 167 / 255)
    }
    static var plasticGreen: Color {
        return Color(red: 61 / 255, green: 160 / 255, blue: 87 / 255)
    }
    static var rainbowRed: Color {
        return Color(red: 255 / 255, green: 59 / 255, blue: 48 / 255)
    }
   
}
