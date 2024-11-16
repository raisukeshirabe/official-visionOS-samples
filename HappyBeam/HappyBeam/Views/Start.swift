/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The start screen for the game.
*/

import SwiftUI
import GroupActivities

struct Start: View {
    @Environment(GameModel.self) var gameModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    @StateObject private var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Image("splashScreen")
                .resizable()
                .frame(width: 337, height: 211)
                .accessibilityHidden(true)
            Text("Happy Beam", comment: "The name of the game.")
                .font(.system(size: 30, weight: .bold))
            Text("Cheer up grumpy clouds by shining a happy beam with your heart.", comment: "This text explains the purpose of the game.")
                .multilineTextAlignment(.center)
                .font(.headline)
                .frame(width: 340)
                .padding(.bottom, 10)
            if gameModel.readyToStart {
                Group {
                    Button {
                        gameModel.isPlaying = true
                        gameModel.timeLeft = GameModel.gameTime
                    } label: {
                        Text("Play Solo", comment: "A game mode where the player plays in single-player mode.")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!gameModel.readyToStart)
                    
                    Button {
                        print("Starting as SharePlay", groupStateObserver.isEligibleForGroupSession)
                        
                        Task {
                            do {
                                try await startSession()
                            } catch {
                                print("SharePlay session failure", error)
                            }
                        }
                    } label: {
                        Text("Play with Friends", comment: "A game mode where the player plays in multi-player mode.")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!groupStateObserver.isEligibleForGroupSession)
                }
                .font(.system(size: 16, weight: .bold))
                .frame(width: 200)
            } else {
                ProgressView("Loading assets…")
            }
            
            Spacer()
        }
        .padding(.horizontal, 150)
        .frame(width: 634, height: 499)
        .onAppear {
            gameModel.menuPlayer.volume = 0.6
            gameModel.menuPlayer.numberOfLoops = -1
            gameModel.menuPlayer.currentTime = 0
            gameModel.menuPlayer.play()
        }
    }
}

#Preview {
    Start()
        .environment(GameModel())
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32,
                style: .continuous
            )
        )
}
