/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that represents a video card.
*/
import SwiftUI
import SwiftData

/// Constants that represent the supported styles for video cards.
enum VideoCardStyle {
    
    /// A style for a full video card.
    ///
    /// This style presents a poster image on top and information about the video
    /// below, including video description and genres.
    case full

    /// A style for cards in the Up Next list.
    ///
    /// This style presents a medium-sized poster image on top and a title string below.
    case upNext
            
    /// A style for cards in library view.
    ///
    /// This style presents a medium sized poster image with a title string below.
    case grid
    
    /// A style for cards in a collection list
    ///
    /// This style presents an image on the leading edge with information about
    /// the video the trailing edge, including video description and genres.
    case stack
    
    /// A style for up next cards in the watch now view.
    ///
    /// This style presents a medium-sized poster image on top and a title string below.
    case half

}

/// A view that represents a video in the library.
///
/// A user can select a video card to view the video details.
struct VideoCardView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var video: Video
    var style: VideoCardStyle = .full
    
    var image: Image {
        Image(video.landscapeImageName)
            .resizable()
    }

    var body: some View {
        switch style {
        case .half:
            PosterCard(image: image, title: video.localizedName)
                .frame(width: isCompact ? Constants.compactVideoCardWidth : Constants.videoCardWidth)
                .clipShape(.rect(cornerRadius: Constants.cornerRadius))
                #if os(iOS) || os(visionOS)
                .hoverEffect()
                #endif
            
        case .upNext:
            PosterCard(image: image, title: video.localizedName)
                .frame(width: Constants.upNextVideoCardWidth)
                .clipShape(.rect(cornerRadius: Constants.cornerRadius))
                #if os(iOS) || os(visionOS)
                .hoverEffect()
                #endif
            
        case .full:
            VStack {
                image.scaledToFill()
                
                InfoView(video: video)
            }
            #if os(macOS)
            .background(.quaternary)
            #else
            .background(.ultraThinMaterial)
            #endif
            #if os(iOS) || os(visionOS)
            .hoverEffect()
            #endif
            .frame(width: isCompact ? Constants.compactVideoCardWidth : Constants.videoCardWidth)
            .clipShape(.rect(cornerRadius: Constants.cornerRadius))
            
        case .grid:
            PosterCard(image: image, title: video.localizedName)
                #if os(iOS) || os(visionOS)
                .hoverEffect()
                #endif
            
        case .stack:
            HStack(spacing: 0) {
                image
                    .scaledToFill()
                    .frame(maxWidth: isCompact ? Constants.stackImageCompactWidth : Constants.stackImageWidth)
                    .cornerRadius(Constants.cornerRadius)
                    .padding([.leading, .vertical], Constants.cardPadding)
                
                InfoView(video: video)
            }
            #if os(macOS)
            .background(.quaternary)
            #else
            .background(.ultraThinMaterial)
            #endif
            #if os(iOS) || os(visionOS)
            .hoverEffect()
            #endif
            .cornerRadius(Constants.cornerRadius)
        }
    }
}

#Preview("Full", traits: .previewData) {
    @Previewable @Query(sort: \Video.id) var videos: [Video]
    return VideoCardView(video: videos.first!, style: .full)
        .frame(height: 350)
}

#Preview("Grid", traits: .previewData) {
    @Previewable @Query(sort: \Video.id) var videos: [Video]
    return VideoCardView(video: videos.first!, style: .grid)
        .frame(width: 200, height: 200)
}

#Preview("Half", traits: .previewData) {
    @Previewable @Query(sort: \Video.id) var videos: [Video]
    return VideoCardView(video: videos.first!, style: .half)
        .frame(width: 200, height: 200)
}

#Preview("Stack", traits: .previewData) {
    @Previewable @Query(sort: \Video.id) var videos: [Video]
    return VideoCardView(video: videos.first!, style: .stack)
        .frame(height: 200)
}

#Preview("UpNext", traits: .previewData) {
    @Previewable @Query(sort: \Video.id) var videos: [Video]
    return VideoCardView(video: videos.first!, style: .upNext)
        .frame(height: 150)
}

