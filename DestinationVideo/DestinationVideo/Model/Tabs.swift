/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A description of the tabs that the app can present.
*/

import SwiftUI

/// A description of the tabs that the app can present.
enum Tabs: Equatable, Hashable, Identifiable {
    case watchNow
    case new
    case favorites
    case library
    case search
    case collections(Category)
    case animations(Category)
    
    var id: Int {
        switch self {
        case .watchNow: 2001
        case .new: 2002
        case .favorites: 2003
        case .library: 2004
        case .search: 2005
        case .collections(let category): category.id
        case .animations(let category): category.id
        }
    }
    
    var name: String {
        switch self {
        case .watchNow: String(localized: "Watch Now", comment: "Tab title")
        case .new: String(localized: "New", comment: "Tab title")
        case .library: String(localized: "Library", comment: "Tab title")
        case .favorites: String(localized: "Favorites", comment: "Tab title")
        case .search: String(localized: "Search", comment: "Tab title")
        case .collections(_): String(localized: "Collections", comment: "Tab title")
        case .animations(_): String(localized: "Animations", comment: "Tab title")
        }
    }
    
    var customizationID: String {
        return "com.example.apple-samplecode.DestinationVideo." + self.name
    }

    var symbol: String {
        switch self {
        case .watchNow: "play"
        case .new: "bell"
        case .library: "books.vertical"
        case .favorites: "heart"
        case .search: "magnifyingglass"
        case .collections(_): "list.and.film"
        case .animations(_): "list.and.film"
        }
    }
    
    var isSecondary: Bool {
        switch self {
        case .watchNow, .library, .new, .favorites, .search:
            false
        case .animations(_), .collections(_):
            true
        }
    }
}
