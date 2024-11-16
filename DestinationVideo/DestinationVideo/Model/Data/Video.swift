/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model class that defines the properties of a video.
*/

import Foundation
import SwiftData
import CoreMedia
import SwiftUI

/// A model class that defines the properties of a video.
@Model
final class Video: Identifiable {
    @Relationship(inverse: \Person.appearsIn)
    var actors: [Person]
    
    @Relationship(inverse: \Person.wrote)
    var writers: [Person]
    
    @Relationship(inverse: \Person.directed)
    var directors: [Person]
    
    @Relationship(inverse: \Genre.videos)
    var genres: [Genre]
    
    @Relationship(inverse: \UpNextItem.video)
    var upNextItem: UpNextItem?
    
    private var categoryIDs: [Int]
    
    @Transient
    var categories: [Category] {
        get {
            categoryIDs.compactMap { Category(rawValue: $0) }
        }
        set {
            categoryIDs = newValue.map(\.rawValue)
        }
    }
    
    var id: Int
    var url: URL
    var imageName: String
    var name: String
    var synopsis: String
    var yearOfRelease: Int
    var duration: Int
    var startTime: CMTimeValue
    var contentRating: String
    var isHero: Bool
    var isFeatured: Bool
    
    init(
        id: Int,
        name: String,
        synopsis: String,
        actors: [Person] = [],
        writers: [Person] = [],
        directors: [Person] = [],
        genres: [Genre] = [],
        categoryIDs: [Int] = [],
        url: URL,
        imageName: String,
        yearOfRelease: Int = 2023,
        duration: Int = 0,
        startTime: CMTimeValue = 0,
        contentRating: String = "NR",
        isHero: Bool = false,
        isFeatured: Bool = false
    ) {
        self.actors = actors
        self.writers = writers
        self.directors = directors
        self.genres = genres
        self.categoryIDs = categoryIDs
        self.id = id
        self.url = url
        self.imageName = imageName
        self.name = name
        self.synopsis = synopsis
        self.yearOfRelease = yearOfRelease
        self.duration = duration
        self.startTime = startTime
        self.contentRating = contentRating
        self.isHero = isHero
        self.isFeatured = isFeatured
    }
}

extension Video {
    var formattedDuration: String {
        Duration.seconds(duration)
            .formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
    
    var formattedYearOfRelease: String {
        yearOfRelease
            .formatted(.number.grouping(.never))
    }
    
    var landscapeImageName: String {
        "\(imageName)_landscape"
    }
    
    var portraitImageName: String {
        "\(imageName)_portrait"
    }
    
    var localizedName: String {
        String(localized: LocalizedStringResource(stringLiteral: self.name))
    }
    
    var localizedSynopsis: String {
        String(localized: LocalizedStringResource(stringLiteral: self.synopsis))
    }
    
    var localizedContentRating: String {
        String(localized: LocalizedStringResource(stringLiteral: self.contentRating))
    }
    
    /// A url that resolves to specific local or remote media.
    var resolvedURL: URL {
        if url.isFileURL {
            guard let fileURL = Bundle.main
                .url(forResource: url.host(), withExtension: nil) else {
                fatalError("Attempted to load a nonexistent video: \(String(describing: url.host()))")
            }
            return fileURL
        } else {
            return url
        }
    }
    
    /// A Boolean value that indicates whether the video is hosted in a remote location.
    var hasRemoteMedia: Bool {
        !url.isFileURL
    }
    
    var imageData: Data {
        PlatformImage(named: landscapeImageName)?.imageData ?? Data()
    }
    
    func toggleUpNext(in context: ModelContext) {
        if let upNextItem {
            context.delete(upNextItem)
            self.upNextItem = nil
        } else {
            let item = UpNextItem(video: self)
            context.insert(item)
            self.upNextItem = item
        }
    }
}
