/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Class for working with audio mixer.
*/

import RealityKit

@Observable
final class AudioMixerStorage {

    let entity = Entity()

    var musicLevel: Audio.Decibel = .zero {
        didSet {
            updateAudioMixGroup(gain: musicLevel, for: .music)
        }
    }

    var spaceshipLevel: Audio.Decibel = .zero {
        didSet {
            updateAudioMixGroup(gain: spaceshipLevel, for: .spaceship)
        }
    }

    var planetsLevel: Audio.Decibel = .zero {
        didSet {
            updateAudioMixGroup(gain: planetsLevel, for: .planets)
        }
    }

    var collisionsLevel: Audio.Decibel = .zero {
        didSet {
            updateAudioMixGroup(gain: collisionsLevel, for: .collisions)
        }
    }

    func updateAudioMixGroup(gain: Audio.Decibel, for mixGroup: MixGroup) {
        var audioMixGroups = entity.components[AudioMixGroupsComponent.self] ?? .init()
        var group = AudioMixGroup(name: mixGroup.rawValue)
        group.gain = gain
        audioMixGroups.set(group)
        entity.components.set(audioMixGroups)
    }
}

enum MixGroup: String, CaseIterable {
    case music = "Music"
    case planets = "Planets"
    case spaceship = "Spaceship"
    case collisions = "Collisions"
}
