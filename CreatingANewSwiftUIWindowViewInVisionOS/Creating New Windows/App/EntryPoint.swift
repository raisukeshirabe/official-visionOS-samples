/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI

@main
struct EntryPoint: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        
        /// The `WindowGroup` for each newly created window in the app's main view.
        WindowGroup("New Window", for: NewWindowID.ID.self) { $id in
            NewWindowView(id: id ?? 1)
        }
    }
}
