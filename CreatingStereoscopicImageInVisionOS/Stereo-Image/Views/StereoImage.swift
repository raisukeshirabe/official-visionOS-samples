/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays a text and a stereoscopic image in a vertical stack.
*/

import SwiftUI
import RealityKit

/// A view that displays a text and a stereoscopic image in a vertical stack.
struct StereoImage: View {
    var body: some View {
        /// The amount of space between the text and the image.
        let spacing: CGFloat = 10.0

        /// The amount of padding for the vertical stack.
        let padding: CGFloat = 40.0

        VStack(spacing: spacing) {
            /// The text that displays on top of the stack.
            Text("Stereoscopic Image Example")
                .font(.largeTitle)

            RealityView { content in
                /// The creator instance of `StereoImageCreator`.
                let creator = StereoImageCreator()

                /// The image entity that `StereoImageCreator` generates.
                guard let entity = await creator.createImageEntity() else {
                    print("Failed to create the stereoscopic image entity.")
                    return
                }

                // Add the image entity to the reality view.
                content.add(entity)
            }
        }
        // Apply padding to the vertical stack.
        .padding(padding)
    }
}
