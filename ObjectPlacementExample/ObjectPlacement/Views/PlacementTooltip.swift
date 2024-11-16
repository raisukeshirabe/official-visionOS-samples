/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The tooltip displayed near the placement target if the user can’t place an object.
*/

import SwiftUI

struct PlacementTooltip: View {
    var placementState: PlacementState

    var body: some View {
        if let message {
            TooltipView(text: message)
        }
    }

    var message: String? {
        // Decide on a message to display, in order of importance.
        if !placementState.planeToProjectOnFound {
            return "Point the device at a horizontal surface nearby."
        }
        if placementState.collisionDetected {
            return "The space is occupied."
        }
        if !placementState.userPlacedAnObject {
            return "Tap to place objects."
        }
        return nil
    }
}

#Preview(windowStyle: .plain) {
    VStack {
        PlacementTooltip(placementState: PlacementState())
        PlacementTooltip(placementState: PlacementState().withPlaneFound())
        PlacementTooltip(placementState:
            PlacementState()
                .withPlaneFound()
                .withCollisionDetected()
        )
    }
}

private extension PlacementState {
    func withPlaneFound() -> PlacementState {
        planeToProjectOnFound = true
        return self
    }

    func withCollisionDetected() -> PlacementState {
        activeCollisions = 1
        return self
    }
}
