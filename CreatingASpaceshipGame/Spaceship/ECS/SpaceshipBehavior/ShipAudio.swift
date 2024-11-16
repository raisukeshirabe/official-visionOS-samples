/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Component and System for updating spaceship's audio.
*/

import CoreAudio
import RealityKit
import AVFAudio

class ShipAudioSystem: System {

    static let query = EntityQuery(
        where: (
            .has(ShipAudioComponent.self) &&
            .has(ThrottleComponent.self)
        )
    )
    static let turbineQuery = EntityQuery(where: .has(TurbineAudioComponent.self))

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        var throttle: Float = 0

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {

            throttle = entity.components[ThrottleComponent.self]!.throttle

            for engineName in ["LeftEngine", "RightEngine"] {
                let engine = entity.findEntity(named: engineName)!
                let exhaust = engine.findEntity(named: "AudioSource-EngineExhaust")!
                updateExhaust(exhaust, throttle: throttle)
            }
        }

        for entity in context.entities(matching: Self.turbineQuery, updatingSystemWhen: .rendering) {
            if let component = entity.components[TurbineAudioComponent.self],
               let audioUnit = component.audioUnit {
                audioUnit.throttle = throttle
            }
        }
    }

    // Modulates the volume of the exhaust, based on throttle input.
    func updateExhaust(_ exhaust: Entity, throttle: Float) {
        let gain = decibels(amplitude: Double(throttle))
        exhaust.components[SpatialAudioComponent.self]!.gain = gain
    }
}

struct TurbineAudioComponent: Component {
    var audioUnit: AudioUnitTurbine?
}

struct ShipAudioComponent: Component {
    init() {
        ShipAudioSystem.registerSystem()
    }
}

func decibels(amplitude: Double) -> Double { 20 * log10(amplitude) }
