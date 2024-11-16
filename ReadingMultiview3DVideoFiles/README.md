# Reading multiview 3D video files

Render single images for the left eye and right eye from a multiview High Efficiency Video Coding format file by reading individual video frames.

## Overview

Multiview High Efficiency Video Coding (MV-HEVC) media files contain information to produce stereoscopic frames, one for the left eye and one for the right, to create an effect of depth and allow for 3D video. This is the standard format for presenting 3D video in visionOS, encoded as MPEG-4 or QuickTime files.

Previewing and testing MV-HEVC files without hardware requires the ability to load, view, and step through the video data on a timeline. This sample app opens a media file, checking for the MV-HEVC format, then presents a view containing the individual frames at the timestamp. Step through the timeline by dragging the slider to a specific timestamp, or advance to the next frame by pressing the Space bar.

For the full details of the MV-HEVC format, see [Apple HEVC Stereo Video - Interoperability Profile (PDF)](https://developer.apple.com/av-foundation/HEVC-Stereo-Video-Profile.pdf) and [ISO Base Media File Format and Apple HEVC Stereo Video (PDF)](https://developer.apple.com/av-foundation/Stereo-Video-ISOBMFF-Extensions.pdf). 

## Load and inspect the media asset

The app first displays a button labeled Open MVHEVC File. When selected, the button presents an [`NSOpenPanel`][1] for choosing video media. Next, the app initializes a [`MediaDetailViewModel`][media-detail], loading this file as an [`AVURLAsset`][2]. Before opening the file to present any elements for a stereo video frame, the app ensures a playable, readable file, and gets its total length in time. This is all performed in the initializer.

``` swift
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
```
[View in Source][media-detail]

## Load track data and timestamps

After confirming the track is readable video data, the app initializes a [`StereoViewModel`][stereo-view] by calling [`AVURLAsset.loadTracks(withMediaCharacteristic:completionHandler:)`][3] requesting a [`.containsStereoMultiviewVideo`][4] track. This check confirms that the file meets the MV-HEVC specification and has valid stereo data.

``` swift
if let track = try await asset.loadTracks(withMediaCharacteristic: .containsStereoMultiviewVideo).first {
    self.track = track
```
[View in Source][5]

Next, the app pulls available timestamps for each frame in the track by calling [`presentationTimesFor(track:asset:)`][load-frame-times]. The app places a video sample cursor at the start of the track with [`makeSampleCursorAtFirstSampleInDecodeOrder()`][6], then creates a new [`AVSampleBufferGenerator`][7] and [`AVSampleBufferRequest`][8].

``` swift
guard let cursor = track.makeSampleCursorAtFirstSampleInDecodeOrder() else {
    return []
}
let sampleBufferGenerator = AVSampleBufferGenerator(asset: asset, timebase: nil)
var presentationTimes = [CMTime]()
let request = AVSampleBufferRequest(start: cursor)
var numSamples: Int64 = 0
```
[View in Source][load-frame-times]

To read the timestamps, obtain the sample buffer for the current cursor from [`makeSampleBuffer(for:)`][9], then add the [`presentationTimeStamp`][10] for the frame. The cursor steps forward by calling [`stepInDecodeOrder(byCount:)`][11], reading and caching timestamps for each frame in the buffer. When `stepInDecodeOrder(byCount:)` returns no next frame, sample times are in the cache and reading the video track completes.

``` swift
repeat {
    let buf = try sampleBufferGenerator.makeSampleBuffer(for: request)
    presentationTimes.append(buf.presentationTimeStamp)
    numSamples = cursor.stepInDecodeOrder(byCount: 1)
} while numSamples == 1
```
[View in Source][load-frame-times]

## Load video layer information

After preparing timestamps, the app calls [`loadVideoLayerIdsForTrack()`][load-video-layers] to get the layer IDs for the two tracks associated with the left and right eyes. The app calls [`AVAssetTrack.load(_:)`][12] to retrieve metadata, then filters the layer data out of the first available track's [`tagCollections`][13]. The filter predicate is [`CMTag.value(onlyIfMatching:)`][14], extracting only video layer IDs.

``` swift
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
```
[View in Source][load-video-layers]

## Load video frames from buffers

With the timestamp and left eye and right eye video layers identified, `readBufferFromAsset(at:)` calls the [`readNextBufferFromAsset()`][read-next-frames] method of the app to retrieve and display the frame data. The method starts with a series of `guard` checks to ensure read access to the track, creates a local copy of the sample buffer by calling [`copyNextSampleBuffer()`][16], and retrieves the tagged video buffers from the track.

``` swift
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
```
[View in Source][read-next-frames]

The app parses each [`.pixelBuffer`][17] from the returned sample buffers into an image for display using [`CIImage(cvPixelBuffer:)`][18]. The app creates an [`NSImage`][21] and sets it to the view content as either `leftEye` or `rightEye` depending on whether the view contains a [`.stereoView`][19] for the left or right eye.

``` swift
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
```
[View in Source][read-next-frames]

[1]:    https://developer.apple.com/documentation/appkit/nsopenpanel
[2]:    https://developer.apple.com/documentation/avfoundation/avurlasset
[3]:    https://developer.apple.com/documentation/avfoundation/avasset/3746530-loadtracks
[4]:    https://developer.apple.com/documentation/avfoundation/avmediacharacteristic/4165297-containsstereomultiviewvideo
[5]:    x-source-tag://InitStereoModel
[6]:    https://developer.apple.com/documentation/avfoundation/avassettrack/1387226-makesamplecursoratfirstsampleind
[7]:    https://developer.apple.com/documentation/avfoundation/avsamplebuffergenerator
[8]:    https://developer.apple.com/documentation/avfoundation/avsamplebufferrequest
[9]:    https://developer.apple.com/documentation/avfoundation/avsamplebuffergenerator/3950877-makesamplebuffer
[10]:   https://developer.apple.com/documentation/coremedia/cmsamplebuffer/3242559-presentationtimestamp
[11]:   https://developer.apple.com/documentation/avfoundation/avsamplecursor/1389606-stepindecodeorder
[12]:   https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading/3747326-load
[13]:   https://developer.apple.com/documentation/coremedia/cmformatdescription/4211327-tagcollections
[14]:   https://developer.apple.com/documentation/coremedia/cmtag/4183777-value
[15]:   https://developer.apple.com/documentation/avfoundation/avassetreader/status/reading
[16]:   https://developer.apple.com/documentation/avfoundation/avassetreaderoutput/1385732-copynextsamplebuffer
[17]:   https://developer.apple.com/documentation/coremedia/cmtaggedbuffer/buffer/pixelbuffer
[18]:   https://developer.apple.com/documentation/coreimage/ciimage/1438072-init
[19]:   https://developer.apple.com/documentation/coremedia/cmtag/4211331-stereoview
[21]:   https://developer.apple.com/documentation/appkit/nsimage

[media-detail]:         x-source-tag://MediaDetailViewModel
[stereo-view]:          x-source-tag://StereoViewModel
[load-frame-times]:     x-source-tag://LoadFrameTimes
[load-video-layers]:    x-source-tag://LoadVideoLayers
[read-asset-buffer]:    x-source-tag://ReadAssetBuffer
[read-next-frames]:     x-source-tag://ReadNextFrames
