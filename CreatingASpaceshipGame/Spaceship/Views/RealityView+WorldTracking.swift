/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
SpatialTrackingSession setup to enable world tracking.
*/

import SwiftUI
import RealityKit

#if os(iOS)

extension RealityKit.RealityViewCameraContent {
    func setupWorldTracking() async {
        let configuration = SpatialTrackingSession.Configuration(
            tracking: [.plane],
            sceneUnderstanding: [.shadow],
            camera: .back
        )
        let session = SpatialTrackingSession()
        _ = await session.run(configuration)
    }
}

#endif
