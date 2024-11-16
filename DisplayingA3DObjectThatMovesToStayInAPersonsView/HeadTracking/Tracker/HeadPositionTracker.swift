/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object that enables world tracking and retrieves the transform of the device.
*/

import SwiftUI
import ARKit

/// The `HeadPositionTracker` class starts a world-tracking session and gets the device's pose and anchors.
class HeadPositionTracker: ObservableObject {
    /// The instance of the `ARKitSession` for world tracking.
    let arSession = ARKitSession()
    
    /// The instance of a new `WorldTrackingProvider` for world tracking.
    let worldTracking = WorldTrackingProvider()

    /// The initializer for the tracker to check through the requirements for world tracking
    /// and start the world-tracking session.
    init() {
        Task {
            // Check whether the device supports world tracking.
            guard WorldTrackingProvider.isSupported else {
                print("WorldTrackingProvider is not supported on this device")
                return
            }
            do {
                // Attempt to start an ARKit session with the world-tracking provider.
                try await arSession.run([worldTracking])
            } catch let error as ARKitSession.Error {
                // Handle any potential ARKit session errors.
                print("Encountered an error while running providers: \(error.localizedDescription)")
            } catch let error {
                // Handle any unexpected errors.
                print("Encountered an unexpected error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Get the current position of the device.
    func originFromDeviceTransform() -> simd_float4x4? {
        /// The anchor of the device at the current time.
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return nil
        }
            
        // Return the device's transform.
        return deviceAnchor.originFromAnchorTransform
    }
}

