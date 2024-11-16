/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The delete button attached to objects.
*/

import SwiftUI

struct DeleteButton: View {
    var deletionHandler: (() -> Void)?

    var body: some View {
        Button {
            if let deletionHandler {
                deletionHandler()
            }
        } label: {
            Image(systemName: "trash")
        }
        .accessibilityLabel("Delete object")
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .plain) {
    DeleteButton()
}

