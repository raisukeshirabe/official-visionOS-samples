/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Presents a button for the selection of media, and populates the image viewer from the selected file.
*/

import SwiftUI

struct LaunchView: View {
    @State private var filename: URL?
    var body: some View {
        if let filename {
            MediaDetailView(filename: filename)
        } else {
            VStack {
                Text("MVHEVC Stereo Image Viewer")
                    .font(.largeTitle)
                    .padding()
                Button("Open MVHEVC File") {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK {
                        self.filename = panel.url
                    }
                }
                .background(.blue)
                .cornerRadius(30)
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
