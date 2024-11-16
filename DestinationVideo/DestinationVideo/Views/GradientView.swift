/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A gradient view.
*/

import SwiftUI

/// A view that displays a horizontal and vertical gradient.
struct GradientView: View {
    
    /// A fill style for the gradient.
    let style: any ShapeStyle
    
    /// Thje direction of the gradient.
    var direction: Axis = .vertical
    
    /// The height of the view in points.
    var height: CGFloat? = nil
    
    /// The width of the view in points.
    var width: CGFloat? = nil
    
    /// The start point of the gradient.
    ///
    /// This value can be `.top` or .`bottom`.
    let startPoint: UnitPoint
    
    var endPoint: UnitPoint {
        if direction == .horizontal {
            return startPoint == .leading ? .trailing : .leading
        } else {
            return startPoint == .top ? .bottom : .top
        }
    }
    
    var body: some View {
        Rectangle()
            .fill(AnyShapeStyle(style))
            .frame(height: height)
            .frame(width: width)
            .mask {
                LinearGradient(colors: [.black, .clear],
                               startPoint: startPoint,
                               // Set the end point to be the opposite of the start.
                               endPoint: endPoint)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
    
}

#Preview("vertical") {
    GradientView(style: .blue.opacity(0.5), height: 200, startPoint: .bottom)
        .ignoresSafeArea()
}

#Preview("horizontal") {
    GradientView(style: .blue.opacity(0.5), direction: .horizontal, startPoint: .leading)
        .ignoresSafeArea()
}
