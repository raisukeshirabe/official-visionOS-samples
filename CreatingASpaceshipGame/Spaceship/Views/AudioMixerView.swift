/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Custom view for audio mixer sliders.
*/

import SwiftUI

struct AudioMixerView: View {

    @Bindable var mixer: AudioMixerStorage

    var body: some View {
        VStack {
            DecibelsSlider(name: MixGroup.music.rawValue, decibels: $mixer.musicLevel)
            DecibelsSlider(name: MixGroup.planets.rawValue, decibels: $mixer.planetsLevel)
            DecibelsSlider(name: MixGroup.spaceship.rawValue, decibels: $mixer.spaceshipLevel)
            DecibelsSlider(name: MixGroup.collisions.rawValue, decibels: $mixer.collisionsLevel)
        }
        .padding()
    }
}
