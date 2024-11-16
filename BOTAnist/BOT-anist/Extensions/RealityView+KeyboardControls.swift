/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension on RealityView for accepting movement input.
*/

import SwiftUI
import RealityKit
import Spatial

public extension View {
    
    var movementMultiplier: Float {
        return 100
    }

    /// A dictionary that maps keys to the approriate movement vector.
    fileprivate var keyBindings: [KeyEquivalent: SIMD3<Float>] {[
        // Standard Left-hand WASD
        KeyEquivalent("w"): SIMD3<Float>(x: 0, y: 0, z: -movementMultiplier),
        KeyEquivalent("a"): SIMD3<Float>(x: -movementMultiplier, y: 0, z: 0),
        KeyEquivalent("s"): SIMD3<Float>(x: 0, y: 0, z: movementMultiplier),
        KeyEquivalent("d"): SIMD3<Float>(x: movementMultiplier, y: 0, z: 0),
        
        // Right-Hand IJKL
        KeyEquivalent("i"): SIMD3<Float>(x: 0, y: 0, z: -movementMultiplier),
        KeyEquivalent("j"): SIMD3<Float>(x: -movementMultiplier, y: 0, z: 0),
        KeyEquivalent("k"): SIMD3<Float>(x: 0, y: 0, z: movementMultiplier),
        KeyEquivalent("l"): SIMD3<Float>(x: movementMultiplier, y: 0, z: 0),
        
        // Arrows
        KeyEquivalent.upArrow: SIMD3<Float>(x: 0, y: 0, z: -movementMultiplier),
        KeyEquivalent.leftArrow: SIMD3<Float>(x: -movementMultiplier, y: 0, z: 0),
        KeyEquivalent.downArrow: SIMD3<Float>(x: 0, y: 0, z: movementMultiplier),
        KeyEquivalent.rightArrow: SIMD3<Float>(x: movementMultiplier, y: 0, z: 0),
        
        // Numpad
        KeyEquivalent("8"): SIMD3<Float>(x: 0, y: 0, z: -movementMultiplier),
        KeyEquivalent("4"): SIMD3<Float>(x: -movementMultiplier, y: 0, z: 0),
        KeyEquivalent("2"): SIMD3<Float>(x: 0, y: 0, z: movementMultiplier),
        KeyEquivalent("6"): SIMD3<Float>(x: movementMultiplier, y: 0, z: 0)
    ]}
    
    fileprivate var boundKeys: Set<KeyEquivalent> {
        var ret = Set<KeyEquivalent>()
        for (key, _) in keyBindings {
            ret.insert(key)
        }
        return ret
    }
    
    fileprivate func forEachValidKeyPress(_ press: KeyPress, _ handler: @escaping (SIMD3<Float>) -> Void) {
        if let vector = keyBindings[press.key] {
            handler(vector)
        }
    }
     
    func installTouchControls(appState: AppState) -> some View {
        return onKeyPress(keys: boundKeys, phases: .down) { press in
            appState.robot?.animationState.transition(to: .walkLoop)
            forEachValidKeyPress(press) { vector in
                appState.robot?.movementVector += vector
            }
            
            return .handled
        }
        .onKeyPress(keys: boundKeys, phases: .up) { press in
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.1))
                if appState.robot?.movementVector == .zero {
                    appState.robot?.animationState.transition(to: .walkEnd)
                }
            }
            forEachValidKeyPress(press) { vector in
                appState.robot?.movementVector -= vector
            }
            return .handled
        }
        .onKeyPress(keys: boundKeys, phases: .repeat) { press in
            return .handled
        }
    }
}
