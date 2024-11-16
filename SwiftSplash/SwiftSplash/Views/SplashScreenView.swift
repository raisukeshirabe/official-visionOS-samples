/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view holding the app's splash screen.
*/
import RealityKit
import SwiftUI
struct SplashScreenView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        VStack {
            Text("Swift Splash", comment: "The title of this game.")
                .font(.extraLargeTitle2)
                .fontWeight(.bold)
            Text("Build an epic water ride this adventurous fish won’t forget.", comment: "An explanation of what this game is about.")
                .frame(width: 300)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, -5)
                .padding(.bottom, 10)
                
            if appState.phase == .loadingAssets {
                ProgressView {
                    Text("Loading Assets…", comment: "An explanation for why the game is still loading.")
                }
            } else {
                Button {
                    appState.startBuilding()
                } label: {
                    Text("Start Building", comment: "An action that starts the game.")
                }
                .accessibilityElement()
            }
        }
        .offset(y: 100)
        .frame(maxWidth: 600, maxHeight: 440, alignment: .center)
        .background {
            Image("swiftSplashHero")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: -110)
        }
        .onAppear {
            // Play menu music as content loads.
            appState.music = .menu
        }
    }
}
#Preview {
    SplashScreenView()
        .glassBackgroundEffect()
        .environment(AppState())
}
