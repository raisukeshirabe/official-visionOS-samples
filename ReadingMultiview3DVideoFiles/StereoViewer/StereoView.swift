/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Presents the individual left and right eye images for a frame of an MV-HEVC video file.
*/

import SwiftUI
import AVFoundation

struct StereoView: View {
    let asset: AVURLAsset
    private var stereoViewModel: StereoViewModel
    @State private var sampleNum: Double = 0
    @State private var isEditing = false
    @State private var frameLabelColor = Color.black
    @State private var close = false
    
    init(asset: AVURLAsset) {
        self.asset = asset
        self.stereoViewModel = StereoViewModel(asset: asset)
    }
    
    var body: some View {
        VStack {
            if close {
                LaunchView()
            } else {
                switch stereoViewModel.state {
                case .ready(let times):
                    ready(times)
                case .error(let message):
                    error(message)
                case .loading:
                    loading()
                }
            }
        }
    }
    
    @MainActor @ViewBuilder func ready(_ times: [CMTime]) -> some View {
        Text("MVHEVC Stereo Image Viewer")
            .font(.title)
            .padding()
        HStack {
            // Present the left eye image of the frame.
            Image(nsImage: stereoViewModel.leftEye)
                .resizable()
                .scaledToFit()
                .clipped()
                .frame(width: 320, height: 240)
                .padding()
            // Present the right eye image of the frame.
            Image(nsImage: stereoViewModel.rightEye)
                .resizable()
                .scaledToFit()
                .clipped()
                .frame(width: 320, height: 240)
                .padding()
        }
        Text("Frame #\(Int(sampleNum)) / \(times[Int(sampleNum)].seconds) sec.")
            .font(.title2)
            .foregroundStyle(frameLabelColor)
            .animation(.linear(duration: 0.3), value: frameLabelColor)
        HStack {
            Text("Frame #0")
                .padding()
            if times.count <= 1 {
                Text("NO SAMPLES")
            } else {
                let step: Double = Double(((times.count - 1) / 100) < 1 ? 1 : ((times.count - 1) / 100))
                Slider(value: $sampleNum, in: 0...Double(times.count - 1), step: step) { editing in
                    isEditing = editing
                    frameLabelColor = .green
                    if !editing {
                        frameLabelColor = .red
                        _ = stereoViewModel.readBufferFromAsset(at: Int(sampleNum))
                    }
                }
                Text("Frame #\(Int(times.count - 1))")
                    .padding()
            }
        }
        Text("Press Spacebar to Advance Frame")
            .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
        Text(asset.url.description)
            .font(.caption)
            .padding()
        
        Button("Close") {
            close = true
        }
        .cornerRadius(30)
        
        // Detect user actions to select the next frame.
        Group {
            Button(action: { nextFrame(times) }) {}
                .keyboardShortcut(.space, modifiers: [])
            Button(action: { nextFrame(times) }) {}
                .keyboardShortcut(.rightArrow, modifiers: [])
        }
        .opacity(0)

    }
    
    @ViewBuilder func error(_ message: String) -> some View {
        ScrollView {
            Spacer(minLength: 50)
            Text("Error Loading Media")
                .font(.title)
                .foregroundStyle(.red)
            Text(asset.url.absoluteString)
                .font(.title3)
            Divider()
                .padding()
            Text(message)
                .font(.body)
                .padding()
            Button("OK") {
                close = true
            }
            .background(.blue)
            .cornerRadius(30)
            .padding()
        }
    }
    
    @ViewBuilder func loading() -> some View {
        Text("LOADING VIDEO ASSET...")
        ProgressView()
        Text(asset.url.absoluteString)
            .font(.footnote)
            .padding()
    }
    
    func nextFrame(_ times: [CMTime]) {
        frameLabelColor = .red
        if Int(sampleNum) < times.count - 1 {
            sampleNum += 1
            stereoViewModel.readNextBufferFromAsset()
        }
    }
}
