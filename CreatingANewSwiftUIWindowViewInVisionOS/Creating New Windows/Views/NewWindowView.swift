/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that displays a unique identifier for each spawned window.
*/

import SwiftUI

/// A SwiftUI view that each new window uses on creation.
struct NewWindowView: View {
    /// The `id` value acts as the main identifier for the new view.
    let id: Int
    
    var body: some View {
        // Create a text view that displays
        // the window's `id` value.
        Text("New window number \(id)")
    }
}
