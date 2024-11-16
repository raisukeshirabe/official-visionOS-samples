/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The score screen for single player.
*/

import SwiftUI

struct SoloScore: View {
    @Environment(GameModel.self) var gameModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 15) {
            Image("greatJob")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 497, height: 200, alignment: .center)
                .accessibilityHidden(true)
            Text("Great job!", comment: "Praise for the player.")
                .font(.system(size: 36, weight: .bold))
            Text("You cheered up \(gameModel.score) grumpy clouds.", comment: "This text describes the results of the players efforts in the game.")
                .multilineTextAlignment(.center)
                .font(.headline)
                .frame(width: 340)
                .padding(.bottom, 10)
            Group {
                Button {
                    playAgain()
                } label: {
                    Text("Play Again", comment: "An action the player can take after the game has concluded, to play again.")
                        .frame(maxWidth: .infinity)
                }
                Button {
                    Task {
                        await goBackToStart()
                    }
                } label: {
                    Text("Back to Main Menu", comment: "An action the player can take after the game has concluded, to go back to the main menu.")
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: 260)
        }
        
        .padding(15)
        .frame(width: 634, height: 499)
    }
    
    func playAgain() {
        let inputChoice = gameModel.inputKind
        gameModel.reset()
        
        if beamIntermediate.parent == nil {
            spaceOrigin.addChild(beamIntermediate)
        }
        
        gameModel.isPlaying = true
        gameModel.isInputSelected = true
        gameModel.isCountDownReady = true
        gameModel.inputKind = inputChoice
    }
    
    @MainActor
    func goBackToStart() async {
        await dismissImmersiveSpace()
        gameModel.reset()
    }
}

#Preview {
    SoloScore()
        .environment(GameModel())
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32,
                style: .continuous
            )
        )
}
