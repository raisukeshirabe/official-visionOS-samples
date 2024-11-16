/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Audio related Entity extensions.
*/

import RealityKit
import AVFAudio

extension Entity {
    func prepareAudio(configuration: AudioGeneratorConfiguration = .init(), audioUnit: AUAudioUnit) throws -> AudioGeneratorController {

        // Set the output format on the Audio Unit.
        let format = AVAudioFormat(standardFormatWithSampleRate: 48_000,
                                   channelLayout: .init(layoutTag: configuration.layoutTag)!)

        try audioUnit.outputBusses[0].setFormat(format)

        // Prepare the Audio Unit.
        try audioUnit.allocateRenderResources()

        // Capture the Audio Unit render block.
        let renderBlock = audioUnit.internalRenderBlock

        return try self.prepareAudio(configuration: configuration) { isSilence, timestamp, frameCount, outputData in
            var renderFlags = AudioUnitRenderActionFlags()
            return renderBlock(&renderFlags, timestamp, frameCount, 0, outputData, nil, nil)
        }
    }
}
