/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object that plays the app's sound effects and music.
*/
import AVKit
import RealityKit

/// The kinds of background music that play during different parts of the game.
public enum MusicMode {
    case menu
    case build
    case ride
    
    case silent
    
    var volume: Float {
        switch self {
        case .menu: 0.4
        case .build: 0.4
        case .ride: 0.4
        case .silent: 0.0
        }
    }
}

public final class SoundEffectPlayer {

    public static var shared: SoundEffectPlayer = try! SoundEffectPlayer()

    private static let mutedGain: Audio.Decibel = -.infinity
    private static let unmutedGain: Audio.Decibel = .zero

    private var isMuted = false

    private var playbackControllers: [AudioPlaybackController] = []
    private var soundEffects: [SoundEffect: AudioResource] = [:]

    private init() throws {
        Task {
            // Loop the water seamlessly, starting at a random point in the file to ensure that
            // multiple instances of the water flowing audio are decorrelated.
            soundEffects[.waterFlowing] = try await AudioFileResource(
                named: "waterFlowing",
                configuration: AudioFileResource.Configuration(
                    shouldLoop: true,
                    shouldRandomizeStartTime: true
                )
            )

            // Create a group of fish sounds which from which a random selection is made
            var fishResources: [AudioFileResource] = []
            let fileNames = ["fishSound_longLoudHappy", "fishSound_mediumHappy", "fishSound_quietHappy"]
            for fileName in fileNames {
                fishResources.append(try await AudioFileResource(named: fileName))
            }
            soundEffects[.fishSounds] = try await AudioFileGroupResource(fishResources)

            soundEffects[.selectPiece] = try await AudioFileResource(named: "pickUp")
            soundEffects[.placePiece] = try await AudioFileResource(named: "placePiece")
            soundEffects[.deletePiece] = try await AudioFileResource(named: "deletePiece")
            soundEffects[.startRide] = try await AudioFileResource(named: "startRide")
            soundEffects[.endRide] = try await AudioFileResource(named: "endRide")
        }
    }

    @discardableResult
    public func play(_ soundEffect: SoundEffect, from entity: Entity) -> AudioPlaybackController? {

        guard let audio = soundEffects[soundEffect] else {
            logger.log("Sound effect \(soundEffect.rawValue) has not finished loading. Cannot play yet.")
            return nil
        }

        // Ensure that the same sound is not played repeatedly
        if let inFlightController = playbackControllers(for: soundEffect, from: entity).first {
            return inFlightController
        }

        let controller = entity.playAudio(audio)
        controller.gain = isMuted ? Self.mutedGain : Self.unmutedGain

        // Remove this sound from our tracking once it has stopped playing due to natural causes.
        // This ensures that a sound which has stopped playing is not "resumed" when the game is
        // resumed after having been paused.
        controller.completionHandler = { [weak self, weak controller] in
            guard let self, let controller else { return }
            self.playbackControllers.removeAll { $0 === controller }
        }

        // Track the playback of this file so that it can be paused, resumed, muted, unmuted, and
        // have its gain changed.
        playbackControllers.append(controller)

        return controller
    }

    public func pause(_ soundEffect: SoundEffect, from entity: Entity? = nil) {
        for controller in playbackControllers(for: soundEffect, from: entity) {
            controller.pause()
        }
    }

    public func pauseAll() {
        for controller in playbackControllers {
            controller.pause()
        }
    }

    public func resumeAll() {
        for controller in playbackControllers {
            controller.play()
        }
    }

    public func resume(_ soundEffect: SoundEffect, from entity: Entity? = nil) {
        for controller in playbackControllers(for: soundEffect, from: entity) {
            controller.play()
        }
    }

    public func stopAll() {
        for playbackController in playbackControllers {
            playbackController.stop()
        }
        playbackControllers.removeAll()
    }

    public func mute() {
        isMuted = true
        for playbackController in playbackControllers {
            playbackController.fade(to: -.infinity, duration: 0.5)
        }
    }

    public func unmute() {
        isMuted = false
        for playbackController in playbackControllers {
            playbackController.fade(to: .zero, duration: 0.5)
        }
    }

    private func playbackControllers(for soundEffect: SoundEffect, from entity: Entity? = nil) -> [AudioPlaybackController] {

        guard let audio = soundEffects[soundEffect] else { return [] }

        return playbackControllers
            .filter { $0.resource === audio }
            .filter {
                guard let entity = entity else { return true }
                return $0.entity == entity
            }
    }
}

public enum SoundEffect: String {
    case waterFlowing
    case fishSounds
    case startRide
    case endRide
    case selectPiece
    case placePiece
    case deletePiece
}
