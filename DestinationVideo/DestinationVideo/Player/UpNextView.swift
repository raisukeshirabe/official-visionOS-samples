/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays a list of videos related to the currently playing video.
*/

import SwiftUI

/// A view that displays a list of videos related to the currently playing video.
struct UpNextView: View {
    let title = String(localized: "Up Next", comment: "Used as window title")
    let videos: [Video]
    let model: PlayerModel
    
    @Namespace private var namespace
    
    var body: some View {
        VideoListView(videos: videos, cardStyle: .upNext, namespace: namespace) { video in
            model.loadVideo(video, presentation: .fullWindow)
        }
    }
}
