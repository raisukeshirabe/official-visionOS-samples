/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Tests for Spaceship.
*/

import Testing
@testable import Spaceship

struct ThrottleMappingTests {

    @Test("Throttle is full when the distance between pointer fingertip and thumb tip is 0 cm.")
    func zeroDistance() {
        #expect(PinchToThrottle.computeThrottle(with: .zero) == 1)
    }

    @Test("Throttle is full when the fingertips are touching but the hand-tracking may be fuzzy.")
    func fingersTouching() {
        #expect(PinchToThrottle.computeThrottle(with: 0.01) == 1)
    }

    @Test("Throttle is null when the fingertips are an ergonomic distance apart (8 cm).")
    func fingersWideOpen() {
        #expect(PinchToThrottle.computeThrottle(with: 0.08) == .zero)
    }

    @Test("Throttle is null when something goes horribly wrong and fingertips are tracked as 1 m apart.")
    func absurdFingerDistance() {
        #expect(PinchToThrottle.computeThrottle(with: 1) == .zero)
    }
}
