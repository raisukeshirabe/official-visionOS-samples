/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main content view.
*/

import SwiftUI
import RealityKit
import OSLog
import BOTanistAssets

/// The app's main view.
struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        switch appState.phase {
            case .waitingToStart, .loadingAssets:
                StartScreenView()
            case .playing:
                HStack(spacing: 0) {
                    RobotCustomizationView()
                        .background(.black.opacity(0.08))
                        .ignoresSafeArea(edges: .vertical)
                    RobotView()
                        .ignoresSafeArea(edges: .all)
                }
                .onChange(of: appState.phase) { _, phase in
                    if phase == .playing {
                        appState.startGame()
                    }
                }
            case .exploration:
                #if !os(visionOS)
                ZStack {
                    ExplorationView()
                        .ignoresSafeArea([.container])
                    
                    HStack {
                        Spacer()
                        VStack {
                            OrnamentView()
                                .background(Color(cgColor: CGColor(gray: 0, alpha: 0.5)), in: RoundedRectangle(cornerRadius: 8))
                                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 20))
                            Spacer()
                        }
                    }
                    .ignoresSafeArea()
                }
                #else
                    EmptyView()
                #endif
        }
    }
}

#Preview(traits: .sampleAppState) {
    ContentView()
}
