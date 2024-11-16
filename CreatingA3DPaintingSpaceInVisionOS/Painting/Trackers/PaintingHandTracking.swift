/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An observable object class that enables hand tracking and tracks the motion of the anchors.
*/

import RealityKit
import ARKit

/// The class starts the `ARKitSession` and the `HandTrackingProvider`,
/// then updates the latest left and right hand anchors.
@MainActor class PaintingHandTracking: ObservableObject {
    /// The `ARKitSession` for hand tracking.
    let arSession = ARKitSession()
    
    /// The `HandTrackingProvider` for hand tracking.
    let handTracking = HandTrackingProvider()
    
    /// The current left hand anchor the app detects.
    @Published var latestLeftHand: HandAnchor?
    
    /// The current right hand anchor the app detects.
    @Published var latestRightHand: HandAnchor?
    
    /// Check whether the device supports hand tracking, and start the ARKit session.
    func startTracking() async {
        // Check if the device supports hand tracking.
        guard HandTrackingProvider.isSupported else {
            print("HandTrackingProvider is not supported on this device.")
            return
        }

        do {
            // Start the ARKit session with the `HandTrackingProvider`.
            try await arSession.run([handTracking])
        } catch let error as ARKitSession.Error {
            // Handle any ARKit errors.
            print("Encountered an error while running providers: \(error.localizedDescription)")
        } catch let error {
            // Handle any other unexpected errors.
            print("Encountered an unexpected error: \(error.localizedDescription)")
        }
        
        // Assign the left and right hand based on the anchor updates.
        for await anchorUpdate in handTracking.anchorUpdates {
            switch anchorUpdate.anchor.chirality {
            case .left:
                self.latestLeftHand = anchorUpdate.anchor
            case .right:
                self.latestRightHand = anchorUpdate.anchor
            }
        }
    }
}
