/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that spawns a new SwiftUI view each time someone presses a button.
*/

import SwiftUI

/// A view with a button in the app's main view that
/// spawns a new SwiftUI window when a person presses it.
struct OpenWindowView: View {
    /// The `id` value that the main view uses to identify the SwiftUI window.
    @State var nextWindowID = NewWindowID(id: 1)
    
    /// The environment value for getting an `OpenWindowAction` instance.
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        // Create a button in the center of the window that
        // launches a new SwiftUI window.
        Button("Open a new window") {
            // Open a new SwiftUI window with the assigned ID.
            openWindow(value: nextWindowID.id)
            
            // Increment the `id` value of the `nextWindowID` by 1.
            nextWindowID.id += 1
        }
    }
}

/// A structure that gives each window a unique ID.
struct NewWindowID: Identifiable {
    /// The unique identifier for the window.
    var id: Int
}

