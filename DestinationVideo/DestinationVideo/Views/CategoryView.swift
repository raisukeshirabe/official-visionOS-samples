/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays the videos in a playlist.
*/

import SwiftUI
import SwiftData

/// A view that displays the videos in a playlist.
struct CategoryView: View {
    @Environment(PlayerModel.self) private var player
    @Environment(\.modelContext) private var context

    @State private var navigationPath: [NavigationNode]
    @State private var videos: [Video] = []
    
    private let category: Category
    private let namespace: Namespace.ID
    
    init(
        category: Category,
        namespace: Namespace.ID,
        navigationPath: [NavigationNode]? = nil
    ) {
        self.category = category
        self.namespace = namespace
        self._navigationPath = State(initialValue: navigationPath ?? [NavigationNode]())
    }
    
    var body: some View {
        // Wrap the content in a vertically scrolling view.
        NavigationStack(path: $navigationPath) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text(category.name)
                        .font(.title.bold())
                    
                    Text(category.description)
                        .font(.body)
                    
                    Button("Play", systemImage: "play.fill") {
                        if let firstVideo = videos.first {
                            /// Load the media item for full-window presentation.
                            player.loadVideo(firstVideo, presentation: .fullWindow)
                        }
                    }
                    .buttonStyle(CustomButtonStyle())
                    .padding(.bottom)
                    
                    VStack(spacing: Constants.cardSpacing) {
                        ForEach(videos.filter { $0.categories.contains(category) }) { video in
                            NavigationLink(value: NavigationNode.video(video.id)) {
                                VideoCardView(video: video, style: .stack)
                            }
                            .accessibilityLabel(category.name)
                            .transitionSource(id: video.id, namespace: namespace)

                        }
                        .buttonStyle(buttonStyle)
                    }
                }
                .padding([.horizontal, .bottom], Constants.outerPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationDestinationVideo(in: namespace)
            }
            .scrollClipDisabled()
            .toolbarBackground(.hidden)
            .padding(.top, Constants.categoryTopPadding)
            .onAppear {
                do {
                    // Show videos in the category.
                    var descriptor = FetchDescriptor<Video>()
                    descriptor.sortBy = [SortDescriptor(\.id)]
                    self.videos = try context.fetch(descriptor)
                        .filter { $0.categories.contains(category) }
                } catch {
                    print(error.localizedDescription)
                }
            }
            #if os(tvOS)
            .background(Color("tvBackground"))
            #endif
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
    @Previewable @Namespace var namespace
    
    return CategoryView(category: .extraordinary,
                        namespace: namespace)
}

