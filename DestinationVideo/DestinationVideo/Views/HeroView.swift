/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays the hero video banner.
*/

import SwiftUI
import SwiftData

/// A view that displays the hero video banner.
struct HeroView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    let video: Video
    let namespace: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .leading) {
            Group {
                Image(decorative: video.landscapeImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: Constants.heroViewHeight)
                    .clipped()
                
                // Add a subtle gradient to make the text stand out.
                GradientView(style: .black.opacity(0.6), startPoint: .leading)
                #if os(iOS)
                GradientView(style: .black, height: isCompact ? Constants.compactGradientSize : Constants.gradientSize / 2, startPoint: .bottom)
                #endif
            }
            
            VStack(alignment: .leading, spacing: Constants.verticalTextSpacing) {
                Text(video.localizedName)
                    .font(isCompact ? .title : .largeTitle)
                    .fontWeight(.bold)
                
                Text(video.localizedSynopsis)
                    .font(isCompact ? .caption : .body)
                    .fontWeight(isCompact ? .regular : .semibold)
                
                NavigationLink("Details", value: NavigationNode.video(video.id))
                    #if os(iOS)
                    .buttonStyle(CustomButtonStyle())
                    #endif
            }
            .frame(maxWidth: Constants.heroTextMargin, alignment: .leading)
            .padding(Constants.outerPadding)
            .padding(Constants.extendSafeAreaTV)
        }
        .transitionSource(id: video.id, namespace: namespace)
        .padding(.bottom, isCompact ? 0 : nil)
        .padding(.top, isCompact ? -Constants.compactSafeAreaHeight : -Constants.heroSafeAreaHeight)
        .padding(.horizontal, -Constants.extendSafeAreaTV)
        #if os(tvOS)
        .focusSection()
        #endif
    }
}

#Preview(traits: .previewData) {
    @Previewable @Query(filter: #Predicate<Video> { $0.isHero }, sort: \.id) var heroVideos: [Video]
    @Previewable @Namespace var namespace
    
    return NavigationStack {
        ScrollView {
            if let heroVideo = heroVideos.first {
                HeroView(video: heroVideo, namespace: namespace)
            }
        }
    }
}

