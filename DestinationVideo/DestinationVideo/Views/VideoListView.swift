/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view the presents a horizontally scrollable list of video cards.
*/

import SwiftUI
import SwiftData

/// A view the presents a horizontally scrollable list of video cards.
struct VideoListView: View {
    
    typealias SelectionAction = (Video) -> Void

    private let title: LocalizedStringKey?
    private let videos: [Video]
    private let cardStyle: VideoCardStyle
    private let selectionAction: SelectionAction?
    
    let namespace: Namespace.ID
    
    /// Creates a view to display the specified list of videos.
    ///
    /// - Parameters:
    ///   - title: An optional title to display above the list.
    ///   - videos: The list of videos to display.
    ///   - cardStyle: The style for the video cards.
    ///   - selectionAction: An optional action that you can specify to directly handle the card selection.
    ///   - namespace: The namespace id of the parent view.
    ///
    ///    When the app doesn't specify a selection action, the view presents the card as a `NavigationLink.
    init(
        title: LocalizedStringKey? = nil,
        videos: [Video],
        cardStyle: VideoCardStyle,
        namespace: Namespace.ID,
        selectionAction: SelectionAction? = nil
    ) {
        self.title = title
        self.videos = videos
        self.cardStyle = cardStyle
        self.namespace = namespace
        self.selectionAction = selectionAction
    }
    
    var body: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.cardSpacing) {
                    ForEach(videos) { video in
                        Group {
                            // If the app initializes the view with a selection action closure,
                            // display a video card button that calls it.
                            if let selectionAction {
                                Button {
                                    selectionAction(video)
                                } label: {
                                    VideoCardView(video: video, style: cardStyle)
                                }
                            }
                            // Otherwise, create a navigation link.
                            else {
                                NavigationLink(value: NavigationNode.video(video.id)) {
                                    VideoCardView(video: video, style: cardStyle)
                                }
                            }
                        }
                        .accessibilityLabel(video.localizedName)
                        .transitionSource(id: video.id, namespace: namespace)
                    }
                }
                .buttonStyle(buttonStyle)
                .padding(.leading, Constants.outerPadding)
            }
            .scrollClipDisabled()
        } header: {
            if let title {
                Text(title)
                    .font(.title3.bold())
                    .padding(.vertical, Constants.listTitleVerticalPadding)
                    .padding(.leading, Constants.outerPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
    }
    
    var buttonStyle: some PrimitiveButtonStyle {
        #if os(tvOS)
        .card
        #else
        .plain
        #endif
    }
    
}

#Preview("Full", traits: .previewData) {
    @Previewable @Query(sort: \Video.id) var videos: [Video]
    @Previewable @Namespace var namespace
    
    return NavigationStack {
        VideoListView(title: "Featured", videos: videos, cardStyle: .full, namespace: namespace)
            .frame(height: 380)
    }
}
