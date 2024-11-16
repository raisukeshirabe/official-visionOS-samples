/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A single unit in the app's navigation stack.
*/

import SwiftUI

/// A single unit in the app's navigation stack.
enum NavigationNode: Equatable, Hashable, Identifiable {
    case category(Int)
    case video(Int)
    
    var id: Int {
        switch self {
        case .category(let id): id
        case .video(let id): id
        }
    }
}
