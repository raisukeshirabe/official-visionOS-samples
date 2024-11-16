/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Presents details of the selected media file.
*/

import SwiftUI
import AVFoundation

@MainActor
struct MediaDetailView: View {
    var mediaDetailViewModel: MediaDetailViewModel
    @State var dismiss = false
    @State var retry = false
    var filename: URL
    
    init(filename: URL) {
        mediaDetailViewModel = MediaDetailViewModel(filename: filename)
        self.filename = filename
    }
    
    var body: some View {
        if dismiss {
            StereoView(asset: mediaDetailViewModel.asset)
        } else {
            VStack {
                if retry {
                    LaunchView()
                } else {
                    Text("Media File Status")
                        .font(.title)
                    Text(filename.absoluteString)
                        .font(.body)
                        .padding()
                    if let error = mediaDetailViewModel.error {
                        Text("Error: \(error.localizedDescription)")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.red)
                        Button("OK") {
                            retry = true
                        }
                        .cornerRadius(30)
                        .padding()
                    }
                    if let duration = mediaDetailViewModel.duration {
                        Text("Duration: \(String(Int(duration))) sec.")
                    }
                    if let isPlayable = mediaDetailViewModel.isPlayable {
                        if isPlayable {
                            Text("Playable")
                        } else {
                            Text("NOT Playable")
                                .foregroundStyle(.red)
                        }
                    }
                    if let isReadable = mediaDetailViewModel.isReadable {
                        if isReadable {
                            Text("Readable")
                                .foregroundStyle(.green)
                            Button("Continue") {
                                dismiss = true
                            }
                            .background(.blue)
                            .cornerRadius(30)
                            .padding()
                        } else {
                            Text("NOT Readable")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
    }
}

