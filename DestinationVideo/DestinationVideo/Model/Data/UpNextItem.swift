/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model class that defines the properties of a video item in the up next queue.
*/

import Foundation
import SwiftData

///  A model class that defines the properties of anvideo item in the up next queue.
@Model
final class UpNextItem {
    @Attribute(.unique)
    private var videoID: Int
    
    @Relationship(deleteRule: .nullify)
    var video: Video?
    
    var createdAt: Date
    
    init(video: Video, createdAt: Date = .now) {
        self.videoID = video.id
        self.video = video
        self.createdAt = createdAt
    }
}
