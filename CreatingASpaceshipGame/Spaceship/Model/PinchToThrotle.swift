/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Static data and functions for mapping pinch to throttle.
*/

struct PinchToThrottle {

    // Start the throttle when the fingers are 8 cm apart.
    static let maximumFingerTipDistance: Float = 0.08

    // Throttle is full when fingertips are touching.
    static let minimumFingerTipDistance: Float = 0.01

    // The throttle value in `0...1` from the distance between fingertips.
    static func computeThrottle(with pinchDistance: Float) -> Float {

        let inputRange = minimumFingerTipDistance...maximumFingerTipDistance
        let sanitizedInputRange = 0...maximumFingerTipDistance
        let outputRange: ClosedRange<Float> = 0...1

        // Sometimes the hand-tracking registers the fingertips as 1 cm apart even when they are
        // touching and you can't touch any harder. Resolve this by setting 1 cm as the minimum
        // distance and scaling the input accordingly.
        let sanitizedInput = pinchDistance.map(from: inputRange, to: sanitizedInputRange)

        return (maximumFingerTipDistance - sanitizedInput)
            .map(from: sanitizedInputRange, to: outputRange)
            .clamped(in: outputRange)
    }
}

extension BinaryFloatingPoint {
    func map(from domain: ClosedRange<Self>, to codomain: ClosedRange<Self>) -> Self {
        let proportion = (self - domain.lowerBound) / (domain.upperBound - domain.lowerBound)
        let scale = codomain.upperBound - codomain.lowerBound
        let offset = codomain.lowerBound
        return proportion * scale + offset
    }
}

extension Comparable {
    func clamped(in range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
