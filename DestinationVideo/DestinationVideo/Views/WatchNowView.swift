/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that presents the app's content library.
*/

import SwiftUI
import SwiftData

/// A view that presents the app's content library.
struct WatchNowView: View {
    @State private var navigationPath = [NavigationNode]()
    @Namespace private var namespace
    
    @Query(filter: #Predicate<Video> { $0.isHero }, sort: \.id)
    private var heroVideos: [Video]
    
    @Query(filter: #Predicate<Video> { $0.isFeatured }, sort: \.id)
    private var featuredVideos: [Video]
    
    @Query(sort: \UpNextItem.createdAt)
    private var playlist: [UpNextItem]
    
    var body: some View {
        // Wrap the content in a vertically scrolling view.
        NavigationStack(path: $navigationPath) {
            ScrollView(showsIndicators: false) {
                VStack {
                    if let heroVideo = heroVideos.first {
                        HeroView(video: heroVideo, namespace: namespace)
                    }

                    // Display a horizontally scrolling list of videos and playlists.
                    VStack(spacing: 20) {
                        VideoListView(title: "Featured",
                                      videos: featuredVideos,
                                      cardStyle: .full, namespace: namespace)
                        
                        CategoryListView(title: "Collections",
                                         categoryList: Category.collectionsList, namespace: namespace)
                        
                        CategoryListView(title: "Animations",
                                         categoryList: Category.animationsList, namespace: namespace)

                        if !playlist.isEmpty {
                            VideoListView(title: "Up Next",
                                          videos: playlist.compactMap(\.video),
                                          cardStyle: .half, namespace: namespace)
                        }
                    }
                    .padding(.bottom, Constants.outerPadding)
                }
            }
            .scrollClipDisabled()
            .navigationDestinationVideo(in: namespace)
            .toolbarBackground(.hidden)
            #if os(visionOS)
            .overlay(alignment: .topLeading) {
                ProfileButtonView()
            }
            #endif
        }
    }
}

#Preview(traits: .previewData) {
    WatchNowView()
}

