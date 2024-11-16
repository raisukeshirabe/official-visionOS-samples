/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The play screen for single player.
*/

import SwiftUI

struct SoloPlay: View {
    @Environment(GameModel.self) var gameModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 0) {
                let progress = Float(gameModel.timeLeft) / Float(GameModel.gameTime)
                HStack(alignment: .top) {
                    Button {
                        Task {
                            await dismissImmersiveSpace()
                        }
                        gameModel.reset()
                    } label: {
                        Label("Back", systemImage: "chevron.backward")
                            .labelStyle(.iconOnly)
                    }
                    .offset(x: -23)
                    Text(verbatim: "\(String(format: "%02d", gameModel.score))")
                        .font(.system(size: 60))
                        .bold()
                        .accessibilityLabel(Text("Score",
                                    comment: "For accessibility: A string that indicates this number is the player's current score in the game."))
                        .accessibilityValue(Text(verbatim: "\(gameModel.score)"))
                    .padding(.leading, 0)
                    .padding(.trailing, 60)
                }
                Text("score", comment: "A string that indicates the number immediately above is the player's current score in the game.")
                    .font(.system(size: 30))
                    .bold()
                    .accessibilityHidden(true)
                    .offset(y: -5)
                HStack {
                    Button {
                        gameModel.isMuted.toggle()
                    } label: {
                        Label(
                            gameModel.isMuted
                            ? String(localized: "Play music", comment: "Button to play music")
                            : String(localized: "Stop music", comment: "Button to stop music"),
                            systemImage: gameModel.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill"
                        )
                            .labelStyle(.iconOnly)
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 10)
                    ProgressView(value: (progress > 1.0 || progress < 0.0) ? 1.0 : progress)
                        .contentShape(.accessibility, Capsule().offset(y: -3))
                        .accessibilityLabel(Text(verbatim: ""))
                        .accessibilityValue(Text("\(gameModel.timeLeft) seconds remaining"))
                        .tint(Color(uiColor: UIColor(red: 242 / 255, green: 68 / 255, blue: 206 / 255, alpha: 1.0)))
                        .padding(.vertical, 30)
                    Button {
                        gameModel.isPaused.toggle()
                        gameModel.isMuted.toggle()
                    } label: {
                        if gameModel.isPaused {
                            Label(String(localized: "Play", comment: "Button to play the game"), systemImage: "play.fill")
                                .labelStyle(.iconOnly)
                        } else {
                            Label(String(localized: "Pause", comment: "Button to pause the game"), systemImage: "pause.fill")
                                .labelStyle(.iconOnly)
                        }
                    }
                    .padding(.trailing, 12)
                    .padding(.leading, 10)
                }
                .background(
                    .regularMaterial,
                    in: .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                )
                .frame(width: 260, height: 70)
                .offset(y: 15)
            }
            .padding(.vertical, 12)
        }
        .frame(width: 260)
        .task {
            do {
                #if targetEnvironment(simulator)
                let shouldAddProjector = true
                #else
                let shouldAddProjector = gameModel.inputKind == .alternative
                #endif

                if shouldAddProjector, heart != nil {
                    try await addFloorBeamMaterials()
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        SoloPlay()
            .environment(GameModel())
            .glassBackgroundEffect(
                in: RoundedRectangle(
                    cornerRadius: 32,
                    style: .continuous
                )
            )
    }
}
