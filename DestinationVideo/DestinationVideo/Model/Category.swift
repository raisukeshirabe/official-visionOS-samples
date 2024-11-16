/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Descriptions of the video collections that the app presents.
*/

import SwiftUI

/// Descriptions of the video collections that the app presents.
enum Category: Int, Equatable, Hashable, Identifiable, CaseIterable {
    case cinematic = 1000
    case forest = 1001
    case sea = 1002
    case animals = 1003
    case amazing = 1004
    case extraordinary = 1005
    
    var id: Int {
        rawValue
    }
    
    var name: String {
        switch self {
        case .cinematic: String(localized: "Cinematic Shots", comment: "Collection name")
        case .forest: String(localized: "Forest Life", comment: "Collection name")
        case .sea: String(localized: "By the Sea", comment: "Collection name")
        case .animals: String(localized: "Cute Animals", comment: "Collection name")
        case .amazing: String(localized: "Amazing Animation", comment: "Collection name")
        case .extraordinary: String(localized: "Extraordinary", comment: "Collection name")
        }
    }
    
    var description: String {
        switch self {
        case .cinematic:
            String(localized: """
            Celebrate the art of cinematography with beautifully-captured videos and animation. The perfect collection for any cinema lover.
            """, comment: "The description of a collection of videos.")
        case .forest:
            String(localized: """
            Take a break from the busyness of city life and immerse yourself in nature with a curated collection of videos. \
            Focus your attention on the forests of California and learn about the variety of cool plants.
            """, comment: "The description of a collection of videos.")
        case .sea:
            String(localized: """
            You can almost feel the calming sea breeze and the refreshing ocean mist as you take in the wonder of the vast Pacific Ocean. \
            The perfect collection of videos for those that feel the call of the ocean.
            """, comment: "The description of a collection of videos.")
        case .animals:
            String(localized: """
            Take a closer look at some of nature’s cutest animals. Feathered and shelled friends star in this adorable collection of animal videos. \
            From little birds soaring through the sky to turtles in a lake fighting for the sunniest spot.
            """, comment: "The description of a collection of videos.")
        case .amazing:
            String(localized: """
            Whether you’re a fan of 2D or 3D animation, this collection includes the best of both. Step into the world of a robot botanist with \
            this new series of animated films.
            """, comment: "The description of a collection of videos.")
        case .extraordinary:
            String(localized: """
            Step on to another planet as you follow the robot botanist on its mission to explore the universe and discover new and \
            exciting plant life. Come see what exciting adventures lay in store.
            """, comment: "The description of a collection of videos.")
        }
    }
    
    var tab: Tabs {
        switch self {
        case .cinematic, .forest, .sea, .animals:
                .collections(self)
        case .amazing, .extraordinary:
                .animations(self)
        }
    }
    
    var icon: String {
        switch self {
        default:
            "list.and.film"
        }
    }
    
    var image: String {
        switch self {
        case .cinematic:
            "cinematic_poster"
        case .forest:
            "forest_poster"
        case .sea:
            "sea_poster"
        case .animals:
            "animals_poster"
        case .amazing:
            "amazing_poster"
        case .extraordinary:
            "extraordinary_poster"
        }
    }
    
    var customizationID: String {
        return "com.example.apple-samplecode.DestinationVideo." + self.name
    }
    
    static var collectionsList: [Category] {
        [.cinematic, .forest, .sea, .animals]
    }
    
    static var animationsList: [Category] {
        [.amazing, .extraordinary]
    }
    
    static func findCategory(from id: Int) -> Category? {
        Category.allCases.first { $0.id == id }
    }
}
