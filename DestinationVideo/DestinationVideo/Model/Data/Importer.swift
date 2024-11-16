/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Loads and parses the video metadata into the app.
*/

import Foundation
import SwiftData
import OSLog

/// A video metadata loader.
struct Importer {
    /// A metadata import status logger.
    static let logger = Logger(subsystem: "com.example.DestinationVideo", category: "Import")
    
    /// Loads the video metadata for the app.
    /// - Parameter context: The model context that this function writes the metadata to.
    /// - Parameter isPreview: A Boolean value that indicates whether to import the data for previews.
    @MainActor static func importVideoMetadata(
        into context: ModelContext,
        isPreview: Bool = false
    ) throws {
        logger.info("In Importer.importVideoMetadata")
        
        // If the app isn't loading preview data, checks if import needs to run.
        if !isPreview {
            // If the app already imported the data, then it doesn't import it again.
            guard hasImported == false else { return }
        }
        
        let videos = SampleData.videos
        let people = SampleData.people
        let genres = SampleData.genres
        let mappings = SampleData.relationships
        
        // Uses the relationship mapping for each video to complete the metadata for that video instance.
        mappings.forEach { map in
            if let video = videos.first(where: { $0.id == map.videoID }) {
                video.actors = people.filter { map.actorIDs.contains($0.id) }
                video.directors = people.filter { map.directorIDs.contains($0.id) }
                video.writers = people.filter { map.writerIDs.contains($0.id) }
                video.genres = genres.filter { map.genreIDs.contains($0.id) }
                
                // Registers the completed video metadata into the model context.
                context.insert(video)
            }
        }
        
        // Saves the data from the model context to persistent storage.
        try context.save()
        
        // Indicates that the video metadata has been imported in the user defaults database.
        UserDefaults.standard.set(true, forKey: "hasImported")
    }

    /// A Boolean value that indicates whether data has already been imported.
    static var hasImported: Bool {
        UserDefaults.standard.bool(forKey: "hasImported")
    }
}

