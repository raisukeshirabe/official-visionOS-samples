/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Setup of the scene and views for the app.
*/
import Foundation
import SwiftUI
import TabletopKit
import RealityKit

// MARK: App entrypoint
@MainActor
@main
struct SampleApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup(id: "Volumetric") {
            GameView().volumeBaseplateVisibility(.hidden)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)
    }
}

@MainActor
struct GameView: View {
    @Environment(\.realityKitScene) private var scene
    @State private var game: Game?
    @State private var activityManager: GroupActivityManager?

    init() {
    }

    var body: some View {
        ZStack {
            if let loadedGame = game, activityManager != nil {
                RealityView { (content: inout RealityViewContent) in
                    content.entities.append(loadedGame.renderer.root)
                    content.add(loadedGame.renderer.portalWorld)
                    content.add(loadedGame.renderer.portal)
                }.toolbar() {
                    GameToolbar(game: loadedGame)
                }.tabletopGame(loadedGame.tabletopGame, parent: loadedGame.renderer.root) { _ in
                    GameInteraction(game: loadedGame)
                }
            }
        }
        .task {
            self.game = await Game()
            self.activityManager = .init(tabletopGame: game!.tabletopGame)
        }
    }
}

struct GameToolbar: ToolbarContent {
    let game: Game
    
    init(game: Game) {
        self.game = game
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomOrnament) {
            Button("Reset", systemImage: "arrow.counterclockwise") {
                game.resetGame()
            }
            Spacer()
            Button("SharePlay", systemImage: "shareplay") {
               Task {
                    try! await Activity().activate()
               }
            }
        }
    }
}
