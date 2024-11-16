/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model class that defines the properties of a genre.
*/

import Foundation
import SwiftData

/// A model class that defines the properties of a genre.
@Model
final class Genre: Identifiable {
    @Relationship
    var videos: [Video]
    
    var id: Int
    var name: String
    
    init(
        id: Int,
        name: String,
        videos: [Video] = []
    ) {
        self.videos = videos
        self.id = id
        self.name = name
    }
}

extension Genre {
    var localizedName: String {
        String(localized: LocalizedStringResource(stringLiteral: self.name))
    }
}

extension SampleData {
    @MainActor static let genres = [
        Genre(id: 0, name: "Drama"),
        Genre(id: 1, name: "Romance"),
        Genre(id: 2, name: "Comedy"),
        Genre(id: 3, name: "Action"),
        Genre(id: 4, name: "Adventure"),
        Genre(id: 5, name: "Documentary"),
        Genre(id: 6, name: "Mystery"),
        Genre(id: 7, name: "Animation"),
        Genre(id: 8, name: "Sci-Fi")
    ]
}
