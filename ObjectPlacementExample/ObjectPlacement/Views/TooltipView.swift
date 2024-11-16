/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view for tooltips.
*/

import SwiftUI

struct TooltipView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 220)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .glassBackgroundEffect()
            .allowsHitTesting(false) // Prevent the tooltip from blocking spatial tap gestures.
    }
}

#Preview(windowStyle: .plain) {
    VStack {
        TooltipView(text: "Text")
    }
}
