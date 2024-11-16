/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Helper methods that simplify the ideal video player placement calculation.
*/

import Foundation

#if os(macOS)
extension PlayerWindow {
    /// Calculates the aspect ratio of the specified size.
    func aspectRatio(of size: CGSize) -> CGFloat {
        size.width / size.height
    }
    
    /// Calculates the center point of a size so the player appears in the center of the specified rectangle.
    func deltas(
        of size: CGSize,
        _ otherSize: CGSize
    ) -> (width: CGFloat, height: CGFloat) {
        (size.width / otherSize.width, size.height / otherSize.height)
    }
    
    /// Calculates the center point of a size so the player appears in the center of the specified rectangle.
    func position(
        of size: CGSize,
        centeredIn bounds: CGRect
    ) -> CGPoint {
        let midWidth = size.width / 2
        let midHeight = size.height / 2
        return .init(x: bounds.midX - midWidth, y: bounds.midY - midHeight)
    }
    
    /// Calculates the largest size a window can be in the current display, while maintaining the window's aspect ratio.
    func calculateZoomedSize(
        of currentSize: CGSize,
        inBounds bounds: CGRect,
        withAspectRatio aspectRatio: CGFloat,
        andDeltas deltas: (width: CGFloat, height: CGFloat)
    ) -> CGSize {
        if (aspectRatio > 1 && currentSize.height * deltas.width <= bounds.height)
            || (aspectRatio < 1 && currentSize.width * deltas.height <= bounds.width) {
            return .init(
                width: bounds.width,
                height: currentSize.height * deltas.width
            )
        } else {
            return .init(
                width: currentSize.width * deltas.height,
                height: bounds.height
            )
        }
    }
}
#endif
