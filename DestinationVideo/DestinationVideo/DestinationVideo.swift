/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main app structure.
*/

import SwiftUI
import SwiftData
import os

/// The main app structure.
@main
struct DestinationVideo: App {
    /// An object that manages the model storage configuration.
    private let modelContainer: ModelContainer
    
    /// An object that controls the video playback behavior.
    @State private var player: PlayerModel

    #if os(visionOS)
    /// An object that stores the app's level of immersion.
    @State private var immersiveEnvironment = ImmersiveEnvironment()
    /// The content brightness to apply to the immersive space.
    @State private var contentBrightness: ImmersiveContentBrightness = .automatic
    /// The effect modifies the passthrough in immersive space.
    @State private var surroundingsEffect: SurroundingsEffect? = nil
    #endif
    
    var body: some Scene {
        // The app's primary content window.
        WindowGroup {
            ContentView()
                .environment(player)
                .modelContainer(modelContainer)
                #if os(visionOS)
                .environment(immersiveEnvironment)
                #endif
                #if os(macOS)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                #endif
                // Set minimum window size
                #if os(macOS) || os(visionOS)
                .frame(minWidth: Constants.contentWindowWidth, maxWidth: .infinity, minHeight: Constants.contentWindowHeight, maxHeight: .infinity)
                #endif
                // Use a dark color scheme on supported platforms.
                #if os(iOS) || os(macOS)
                .preferredColorScheme(.dark)
                #endif
        }
        #if !os(tvOS)
        .windowResizability(.contentSize)
        #endif

        // The video player window
        #if os(macOS)
        PlayerWindow(player: player)
        #endif
        
        #if os(visionOS)
        // Defines an immersive space to present a destination in which to watch the video.
        ImmersiveSpace(id: ImmersiveEnvironmentView.id) {
            ImmersiveEnvironmentView()
                .environment(immersiveEnvironment)
                .onAppear {
                    contentBrightness = immersiveEnvironment.contentBrightness
                    surroundingsEffect = immersiveEnvironment.surroundingsEffect
                }
                .onDisappear {
                    contentBrightness = .automatic
                    surroundingsEffect = nil
                }
            // Apply a custom tint color for the video passthrough of a person's hands and surroundings.
                .preferredSurroundingsEffect(surroundingsEffect)
        }
        // Set the content brightness for the immersive space.
        .immersiveContentBrightness(contentBrightness)
        // Set the immersion style to progressive, so the user can use the Digital Crown to dial in their experience.
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        #endif
    }
    
    /// Load video metadata and initialize the model container and video player model.
    init() {
        do {
            let modelContainer = try ModelContainer(for: Video.self, Person.self, Genre.self, UpNextItem.self)
            try Importer.importVideoMetadata(into: modelContainer.mainContext)
            self._player = State(initialValue: PlayerModel(modelContainer: modelContainer))
            self.modelContainer = modelContainer
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

/// A global log of events for the app.
let logger = Logger()
