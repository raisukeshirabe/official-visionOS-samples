/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that presents the video player.
*/

import SwiftUI

/// Constants that define the style of controls a player presents.
enum PlayerControlsStyle {
    /// The player uses the system interface that AVPlayerViewController provides.
    case system
    /// The player uses compact controls that display a play/pause button.
    case custom
}

/// A view that presents the video player.
struct PlayerView: View {
    
    static let identifier = "player-view"
    
    let controlsStyle: PlayerControlsStyle
    @State private var showContextualActions = false
    @Environment(PlayerModel.self) private var model
    
    /// Creates a new player view.
    init(controlsStyle: PlayerControlsStyle = .system) {
        self.controlsStyle = controlsStyle
    }

    private var systemPlayerView: some View {
        #if os(macOS)
        // Adds the drag gesture to a transparent overlay and inserts
        // the overlay between the video content and the playback controls.
        let overlay = Color.clear
            .contentShape(.rect)
            .gesture(WindowDragGesture())
            // Enable the window drag gesture to receive events that activate the window.
            .allowsWindowActivationEvents(true)
        return SystemPlayerView(showContextualActions: showContextualActions, overlay: overlay)
        #else
        return SystemPlayerView(showContextualActions: showContextualActions)
        #endif
    }

    var body: some View {
        switch controlsStyle {
        case .system:
            systemPlayerView
                .onChange(of: model.shouldProposeNextVideo) { oldValue, newValue in
                    if oldValue != newValue {
                        showContextualActions = newValue
                    }
                }
        case .custom:
            #if os(visionOS)
            InlinePlayerView()
            #endif
        }
    }
}
