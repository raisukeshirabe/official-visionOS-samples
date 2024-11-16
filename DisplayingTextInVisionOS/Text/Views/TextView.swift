/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that displays multiple lines of text.
*/

import SwiftUI

/// A view that displays multiple text styles in the app's main view.
struct SwiftUIText: View {
    /// The amount of spacing between adjacent text entries.
    let spacing: CGFloat = 30

    var body: some View {
        VStack(spacing: spacing) {
            // Set the style to large title.
            Text("This is a large title").font(.largeTitle)

            // Set the style to subheadline.
            Text("This is a subheadline text").font(.subheadline)

            // Format the text to bold.
            Text("This is a bold text").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)

            // Set the text's color to green.
            Text("This is a green text").foregroundStyle(.green)
        }
    }
}
