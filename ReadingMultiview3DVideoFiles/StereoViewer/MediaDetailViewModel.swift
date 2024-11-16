/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Loads a video file and gets metadata information.
*/

import AVFoundation

/// - Tag: MediaDetailViewModel
@MainActor
@Observable
final class MediaDetailViewModel {
    let asset: AVURLAsset
    var duration: Double?
    var isReadable: Bool?
    var error: Error?
    var isPlayable: Bool?
    
    init(filename: URL) {
        asset = AVURLAsset(url: filename)
        Task { @MainActor in
            do {
                let (duration, isPlayable, isReadable) = try await asset.load(.duration, .isPlayable, .isReadable)
                self.duration = duration.seconds
                self.isPlayable = isPlayable
                self.isReadable = isReadable
            } catch {
                self.error = error
            }
        }
    }
}
