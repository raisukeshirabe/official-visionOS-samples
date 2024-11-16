/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A RealityKit view that plays spatial audio.
*/

import SwiftUI
import RealityKit

/// A view that plays spatial audio that responds to changes in rotation translation of both the source and the listener.
struct SpatialAudioView: View {
    /// The entity to contain the audio sample.
    let entity = Entity()

    /// The gain value of the audio source.
    @State private var gain: Audio.Decibel = .zero

    /// The direct signal that emits from the audio source.
    @State private var directLevel: Audio.Decibel = .zero

    /// The reverb of the audio source.
    @State private var reverbLevel: Audio.Decibel = .zero

    /// The main body view that includes three child views: the audio source, the description, and the configuration.
    var body: some View {
        HStack {
            audioSource

            VStack {
                description
                Spacer()
                configuration
            }
            .padding(30)
            .frame(width: 350)
        }
    }

    /// A view that loads and configures the audio source as an ambient audio entity.
    var audioSource: some View {
        RealityView { content in
            // Add the entity to the `RealityView`.
            content.add(entity)

            /// The name of the audio source.
            let audioName: String = "FunkySynth.m4a"

            /// The configuration to loop the audio file continously.
            let configuration = AudioFileResource.Configuration(shouldLoop: true)

            // Load the audio source and set its configuration.
            guard let audio = try? AudioFileResource.load(
                named: audioName,
                configuration: configuration
            ) else {
                // Handle the error if the audio file fails to load.
                print("Failed to load audio file.")
                return
            }

            /// The focus for the directivity of the spatial audio.
            let focus: Double = 0.5

            // Add a spatial component to the entity that emits in the forward direction.
            entity.spatialAudio = SpatialAudioComponent(directivity: .beam(focus: focus))

            // Set the entity to play audio.
            entity.playAudio(audio)
        }
        // Create an axis representation and add it as a child.
        .onAppear { entity.addChild(AxisVisualizer.make()) }

        // Enable the view to change the gain parameter.
        .onChange(of: gain) { entity.spatialAudio?.gain = gain }

        // Enable the view to change the direct level parameter.
        .onChange(of: directLevel) { entity.spatialAudio?.directLevel = directLevel }

        // Enable the view to change the reverb parameter.
        .onChange(of: reverbLevel) { entity.spatialAudio?.reverbLevel = reverbLevel }
    }

    /// A view that guides people through a series of steps to experience the ambient audio.
    var description: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spatial Audio")
                .font(.title)

            Text("Push the app away from you, then bring it closer to you")
            Text("Notice how the sound gets quieter and louder as it moves")
                .foregroundStyle(.secondary)

            Text("Move the app around you")
            Text("Notice how the sound emanates around you as it moves")
                .foregroundStyle(.secondary)

            Text("Rotate your head")
            Text("Notice how the sound radiates from the app's location")
                .foregroundStyle(.secondary)

            Text("Move your head towards the red axis")
            Text("Notice how the sound gets louder as you move towards the emitter")
                .foregroundStyle(.secondary)
        }
    }

    /// A view that uses the `DecibelSlider` to control the gain value of the audio source.
    var configuration: some View {
        VStack {
            /// The slider to control the gain value.
            DecibelSlider(name: "Gain", value: $gain)

            /// The slider to control the direct level value.
            DecibelSlider(name: "Direct Level", value: $directLevel)

            /// The slider to control the reverb level.
            DecibelSlider(name: "Reverb Level", value: $reverbLevel)
        }
    }
}
