/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Retrieves individual frames of a 3D MV-HEVC video and gets the left and right eye images.
*/

@preconcurrency import AVFoundation
import VideoToolbox
import SwiftUI

enum StereoViewModelState {
    case loading
    case ready(times: [CMTime])
    case error(message: String)
}

/// - Tag: StereoViewModel
@Observable
class StereoViewModel: @unchecked Sendable {
    
    @MainActor var state: StereoViewModelState = .loading
    @MainActor var leftEye = NSImage(systemSymbolName: "eye", accessibilityDescription: nil) ?? NSImage()
    @MainActor var rightEye = NSImage(systemSymbolName: "eye", accessibilityDescription: nil) ?? NSImage()
    
    private let asset: AVURLAsset
    private var framePresentationTimes = [CMTime]()
    private var assetReader: AVAssetReader?
    private var trackOutput: AVAssetReaderTrackOutput?
    private var track: AVAssetTrack?
    private var duration = CMTime.zero
    private var videoLayerIds: [Int64]?

    /// - Tag: InitStereoModel
    init(asset: AVURLAsset) {
        self.asset = asset
        Task.detached {
            do {
                if let track = try await asset.loadTracks(withMediaCharacteristic: .containsStereoMultiviewVideo).first {
                    self.track = track
                    self.framePresentationTimes = try presentationTimesFor(track: track, asset: asset)
                    self.duration = try await asset.load(.duration)
                    self.videoLayerIds = try await loadVideoLayerIdsForTrack(track)
                    if self.readBufferFromAsset(at: 0) {
                        self.publishState(.ready(times: self.framePresentationTimes))
                    }
                } else {
                    self.publishState(.error(message: "NO STEREO MULTIVIEW VIDEO TRACK IN ASSET"))
                }

            } catch {
                self.publishState(.error(message: error.localizedDescription))
            }
        }
    }
    
    private func publishState(_ state: StereoViewModelState) {
        Task {
            await MainActor.run {
                self.state = state
            }
        }
    }
    
    /// - Tag: ReadAssetBuffer
    func readBufferFromAsset(at sampleNum: Int) -> Bool {
        guard let track, let videoLayerIds else {
            publishState(.error(message: "NO ASSET TRACK OR TAG ID's"))
            return false
        }
        guard !framePresentationTimes.isEmpty else {
            publishState(.error(message: "NO SAMPLES FOUND IN VIDEO TRACK"))
            return false
        }
        guard sampleNum >= 0 && sampleNum < framePresentationTimes.count else {
            publishState(.error(message: "UNEXPECTED SAMPLE NUMBER \(sampleNum), MAX \(framePresentationTimes.count - 1)"))
            return false
        }
        let time = framePresentationTimes[sampleNum]
        print("READING BUFFER FROM ASSET AT #\(sampleNum), \(time.seconds) SEC.")

        // Create a new asset reader to read the track sequentially.
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            publishState(.error(message: "CANNOT CREATE ASSET READER \(error.localizedDescription)"))
        }
        guard let assetReader else {
            return false
        }
        
        let outputSettings: [String: Any] = [
            AVVideoDecompressionPropertiesKey as String: [kVTDecompressionPropertyKey_RequestedMVHEVCVideoLayerIDs as String: videoLayerIds]
        ]
        trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        guard let trackOutput else {
            publishState(.error(message: "CREATING ASSET READER TRACK OUTPUT"))
            return false
        }
        assetReader.add(trackOutput)
        
        // Set available time range from the current time to end of media, allowing for single steps.
        let remainingDuration = duration - time
        assetReader.timeRange = CMTimeRangeMake(start: time, duration: remainingDuration)
        guard assetReader.startReading() else {
            assert(assetReader.status == .failed)
            publishState(.error(message: "MVHEVC ENCODING EXPECTED IN VIDEO TRACK"))
            return false
        }
        
        readNextBufferFromAsset()
        
        return true
    }
    
    // Read the next frame as a sample buffer, and show the images for the left and right eye.
    /// - Tag: ReadNextFrames
    func readNextBufferFromAsset() {
        guard let assetReader, let trackOutput else {
            return
        }
        guard assetReader.status == .reading else {
            publishState(.error(message: "UNEXPECTED STATUS \(assetReader.status)"))
            return
        }
        guard let sampleBuffer = trackOutput.copyNextSampleBuffer() else {
            publishState(.error(message: "READING SAMPLE BUFFER, STATUS \(assetReader.status), ERROR \(String(describing: assetReader.error))"))
            return
        }
        guard let taggedBuffers = sampleBuffer.taggedBuffers else {
            publishState(.error(message: "SAMPLE BUFFER CONTAINS NO TAGGED BUFFERS: \(sampleBuffer)"))
            return
        }
        guard taggedBuffers.count == 2 else {
            publishState(.error(message: "EXPECTED 2 TAGGED BUFFERS, GOT \(taggedBuffers.count)"))
            return
        }
        
        // Read the left and right eye buffers, converting pixel data to images.
        taggedBuffers.forEach { taggedBuffer in
            switch taggedBuffer.buffer {
            case let .pixelBuffer(pixelBuffer):
                let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
                let context: CIContext = CIContext(options: nil)
                let cgImage: CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
                let tags = taggedBuffer.tags
                Task {
                    await MainActor.run {
                        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: 320, height: 240))
                        if tags.contains(.stereoView(.leftEye)) {
                            leftEye = nsImage
                        } else if tags.contains(.stereoView(.rightEye)) {
                            rightEye = nsImage
                        }
                    }
                }
            case .sampleBuffer(let samp):
                publishState(.error(message: "EXPECTED PIXEL BUFFER, GOT SAMPLE BUFFER \(samp)"))
            @unknown default:
                publishState(.error(message: "EXPECTED PIXEL BUFFER TYPE, GOT \(taggedBuffer.buffer)"))
            }
        }
    }
}

// Create an array of presentation times indexed by sample number.
/// - Tag: LoadFrameTimes
private func presentationTimesFor(track: AVAssetTrack, asset: AVAsset) throws -> [CMTime] {
    guard let cursor = track.makeSampleCursorAtFirstSampleInDecodeOrder() else {
        return []
    }
    let sampleBufferGenerator = AVSampleBufferGenerator(asset: asset, timebase: nil)
    var presentationTimes = [CMTime]()
    let request = AVSampleBufferRequest(start: cursor)
    var numSamples: Int64 = 0
    
    repeat {
        let buf = try sampleBufferGenerator.makeSampleBuffer(for: request)
        presentationTimes.append(buf.presentationTimeStamp)
        numSamples = cursor.stepInDecodeOrder(byCount: 1)
    } while numSamples == 1
    return presentationTimes
}

// Load the video layer ID's from an asset's stereo multiview track.
/// - Tag: LoadVideoLayers
private func loadVideoLayerIdsForTrack(_ videoTrack: AVAssetTrack) async throws -> [Int64]? {
    let formatDescriptions = try await videoTrack.load(.formatDescriptions)
    var tags = [Int64]()
    if let tagCollections = formatDescriptions.first?.tagCollections {
        tags = tagCollections.flatMap({ $0 }).compactMap { tag in
            tag.value(onlyIfMatching: .videoLayerID)
        }
    }
    return tags
}
