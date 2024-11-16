/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Class for storing runtime audio objects .
*/

import RealityKit
import CoreAudio

@MainActor
final class SpaceshipAudioStorage {

    var vaporTrailControllers: [EnginePlacement: AudioPlaybackController] = [:]
    var exhaustControllers: [EnginePlacement: AudioPlaybackController] = [:]
    var turbineControllers: [EnginePlacement: AudioGeneratorController] = [:]
    var turbineAudioUnits: [EnginePlacement: AudioUnitTurbine] = [:]

    func prepareAudio(for spaceship: Entity) async throws {
        for enginePlacement in EnginePlacement.allCases {
            let engineName = "\(enginePlacement.rawValue.capitalized)Engine"
            let engine = spaceship.findEntity(named: engineName)!
            try await prepareVaporTrailAudio(on: engine, placement: enginePlacement)
            try await prepareExhaustAudio(on: engine, placement: enginePlacement)
            try await prepareTurbineAudio(on: engine, placement: enginePlacement)
        }
    }

    func play() {
        vaporTrailControllers.values.forEach { $0.playAndFadeIn(duration: 2) }
        exhaustControllers.values.forEach { $0.playAndFadeIn(duration: 2) }
        turbineControllers.values.forEach { $0.play() }
    }

    func fadeOut() async throws {
        vaporTrailControllers.values.forEach { $0.fade(to: -.infinity, duration: 2) }
        exhaustControllers.values.forEach { $0.fade(to: -.infinity, duration: 2) }
        try await Task.sleep(for: .seconds(2))
        vaporTrailControllers.values.forEach { $0.stop() }
        exhaustControllers.values.forEach { $0.stop() }
    }

    func stop() {
        vaporTrailControllers.values.forEach { $0.stop() }
        exhaustControllers.values.forEach { $0.stop() }
        turbineControllers.values.forEach { $0.stop() }
    }

    func prepareVaporTrailAudio(on engine: Entity, placement: EnginePlacement) async throws {
        let audioSource = engine.findEntity(named: "AudioSource-EngineParticles")!
        let audio = try await AudioFileResource(
            named: "VaporTrail",
            configuration: .init(
                shouldLoop: true,
                shouldRandomizeStartTime: true,
                calibration: .absolute(dBSPL: 50),
                mixGroupName: MixGroup.spaceship.rawValue
            )
        )
        vaporTrailControllers[placement] = audioSource.prepareAudio(audio)
    }

    func prepareExhaustAudio(on engine: Entity, placement: EnginePlacement) async throws {
        let audioSource = engine.findEntity(named: "AudioSource-EngineExhaust")!
        let audio = try await AudioFileResource(
            named: "Exhaust",
            configuration: .init(
                shouldLoop: true,
                shouldRandomizeStartTime: true,
                mixGroupName: MixGroup.spaceship.rawValue
            )
        )
        exhaustControllers[placement] = audioSource.prepareAudio(audio)
    }

    func prepareTurbineAudio(on engine: Entity, placement: EnginePlacement) async throws {

        let turbine = engine.findEntity(named: "AudioSource-EngineTurbine")!

        let carrierFrequencyMin: Float = .random(in: 580...620)
        let carrierFrequencyBandwidth: Float = .random(in: 250...300)

        let audioUnit = try await AudioUnitTurbine.instantiate()

        audioUnit.carrierFrequencyMin = carrierFrequencyMin
        audioUnit.carrierFrequencyBandwidth = carrierFrequencyBandwidth
        audioUnit.throttle = .zero

        engine.components.set(TurbineAudioComponent(audioUnit: audioUnit))
        turbineControllers[placement] = try turbine.prepareAudio(
            configuration: .init(mixGroupName: MixGroup.spaceship.rawValue),
            audioUnit: audioUnit
        )
        turbineAudioUnits[placement] = audioUnit
    }
}

extension AudioPlaybackController {
    func playAndFadeIn(duration: TimeInterval) {
        gain = -.infinity
        fade(to: .zero, duration: duration)
        play()
    }

    func stopAndFadeOut(duration: TimeInterval) async throws {
        fade(to: -.infinity, duration: duration)
        try await Task.sleep(for: .seconds(Int(duration)))
        stop()
    }
}

enum EnginePlacement: String, CaseIterable {
    case left, right
}
