/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that creates a 3D depth effect in visionOS.
*/

import SwiftUI

/// A view that creates a 3D effect of a string popping out of the app's
/// main view by displaying multiple text views in a stack.
struct DepthTextView: View {
    /// The text view to which the app applies the 3D effect that extends from the window.
    let text = Text("Hello World").font(.extraLargeTitle)

    /// The scale of the spacing offset between the text layers.
    @State var animationProgress = 0.0

    /// The number of text layers that extend from the window along its z-axis.
    let layers = 5

    /// The number of points between each layer.
    let layerSpacing = 100

    var body: some View {
        // Create a stack of the same text view with different opacities and
        // positions along the z-axes, starting with a blurry shadow version.
        ZStack {
            textShadowView
            textMiddleViews
            textFrontView
        }
        .onAppear(perform: animateWithSpringEffect)
    }
    
    /// A text view that's fully opaque.
    var textFrontView: some View {
        text.offset(z: Double(layerSpacing * layers) * animationProgress)
    }

    /// A series of semitransparent text views along a z-axis.
    var textMiddleViews: some View {
        ForEach(1..<layers, id: \.self) { layer in
            let layerPercent = Double(layer) / Double(layers)
            let maximumOffset = Double(layerSpacing * layers)
            let maximumOpacity = 1.0

            text
                .offset(z: maximumOffset * layerPercent * animationProgress)
                .opacity(maximumOpacity * layerPercent)
        }
    }

    /// A text view that acts as a burry, dark shadow on the SwiftUI window.
    var textShadowView: some View {
        /// The width, in points, of the blur effect relative to the text's edges.
        let blurRadius: CGFloat = 12
        let maximumOpacity = 0.6

        return text
            .foregroundStyle(.black)
            .blur(radius: blurRadius)
            .opacity(maximumOpacity * animationProgress)
    }
    
    /// Updates the value of the offset scale property with a spring animation.
    func animateWithSpringEffect() {
        /// A spring coefficient for a spring animation effect,
        /// in newtons per meter.
        let stiffness: Double = 200

        /// The damping factor of a spring animation's effect,
        /// in newton-seconds per meter.
        let damping: Double = 10

        let spring = Spring(stiffness: stiffness, damping: damping)
        let springAnimation = Animation.interpolatingSpring(spring).delay(1.0)

        // Animate the text popping out of the window with a spring effect.
        withAnimation(springAnimation) { animationProgress = 1.0 }
    }
}

#Preview(windowStyle: .automatic) {
    DepthTextView()
}
