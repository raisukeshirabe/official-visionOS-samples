/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension on RealityView that implements platform-specific gesture controls.
*/

import Foundation
import RealityKit
import SwiftUI

public extension View {
    
    func platformTouchControls(appState: AppState) -> some View {
#if !os(visionOS)
        return simultaneousGesture(DragGesture()
            .onChanged { value in
                let translation = value.translation
                let movementVector = SIMD3<Float>(x: Float(translation.width), y: 0, z: Float(translation.height))
                appState.robot?.movementVector = movementVector
                
                if movementVector != .zero && appState.robot?.animationState == .idle {
                    appState.robot?.animationState.transition(to: .walkLoop)
                }
            }
            .onEnded { value in
                appState.robot?.animationState.transition(to: .walkEnd)
                appState.robot?.movementVector = .zero
            }
        )
#else
        return simultaneousGesture(DragGesture()
            .targetedToEntity(appState.robot?.characterParent ?? Entity()) // This could be nil during app state restore.
            .onChanged { @MainActor value in
                guard let robot = appState.robot else { fatalError("No robot.") }
                let translation = value.translation3D
                let movementVector = SIMD3<Float>(x: Float(translation.x), y: 0, z: Float(translation.z))
                
                // Starting movement while idle
                if robot.movementVector == .zero && movementVector != .zero {
                    robot.animationState.transition(to: .walkLoop)
                }
                
                // Ending movement while walking
                if robot.movementVector != .zero && movementVector == .zero {
                    robot.animationState.transition(to: .walkEnd)
                }
                robot.movementVector = movementVector
                
            } .onEnded { value in
                appState.robot?.movementVector = SIMD3<Float>(x: 0, y: 0, z: 0)
                appState.robot?.animationState.transition(to: .walkEnd)
            }
        )
#endif
    }
}
