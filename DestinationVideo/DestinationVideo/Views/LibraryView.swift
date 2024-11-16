/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays the list of videos the library contains in a grid.
*/

import SwiftUI
import SwiftData

/// A view that displays the list of videos the library contains in a grid.
struct LibraryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Query(sort: \Video.name)
    private var allVideos: [Video]
    
    @Query(sort: \Genre.name)
    private var genres: [Genre]
    
    @Namespace private var namespace
    
    @State private var navigationPath = [NavigationNode]()
    @State private var selectedGenre: Genre?
    
    // Adapt the number columns based on platform and size class.
    private var columns: [GridItem] {
        let gridItem = GridItem(.flexible(), spacing: Constants.cardSpacing)
        let count = horizontalSizeClass == .compact ? Constants.libraryColumnCountCompact : Constants.libraryColumnCount
        return [GridItem](repeating: gridItem, count: count)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            // Wrap the content in a vertically scrolling view.
            ScrollView(showsIndicators: false) {
                VStack {
                    // Wrap the content in a horizontally scrolling view.
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button("All") {
                                selectedGenre = nil
                            }
                            .buttonStyle(PickerButtonStyle(isSelected: selectedGenre == nil))

                            ForEach(genres.sorted { $0.localizedName < $1.localizedName }) { genre in
                                Button(genre.localizedName) {
                                    selectedGenre = genre
                                }
                                .buttonStyle(PickerButtonStyle(isSelected: selectedGenre == genre))
                            }
                        }
                    }
                    .defaultScrollAnchor(.center)
                    .scrollClipDisabled()
                    .padding(.bottom)

                    // Filter videos using the genre a person selects.
                    let videos = selectedGenre?.videos.sorted(by: { $0.id < $1.id }) ?? allVideos.sorted { $0.localizedName < $1.localizedName }
                    LazyVGrid(columns: columns, spacing: Constants.cardSpacing) {
                        ForEach(videos) { video in
                            NavigationLink(value: NavigationNode.video(video.id)) {
                                VideoCardView(video: video, style: .grid)
                            }
                            .transitionSource(id: video.id, namespace: namespace)
                            .accessibilityLabel(video.localizedName)
                            .buttonStyle(buttonStyle)
                        }
                    }
                }
                .navigationDestinationVideo(in: namespace)
                .padding(Constants.outerPadding)
            }
            .scrollClipDisabled()
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

#Preview(traits: .previewData) {
    LibraryView()
}

