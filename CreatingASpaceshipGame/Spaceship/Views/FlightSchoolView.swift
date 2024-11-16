/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Flight school teaches player how to control the spaceship with their hands.
*/

#if os(visionOS)
import SwiftUI
import RealityKit

@MainActor
struct FlightSchoolView: View {

    static let throttleDisplayId: String = "ThrottleDisplay"
    static let pitchRollDisplayId: String = "PitchRollDisplay"

    @State private var throttle: Float = .zero
    @State private var pitch: Float = .zero
    @State private var roll: Float = .zero

    @State private var spaceshipAudio = SpaceshipAudioStorage()

    var body: some View {
        RealityView { content, attachments in
            do {
                let spaceship = try await Entity.makeSpaceship()
                spaceship.scale = .init(repeating: 1.33)
                try await spaceshipAudio.prepareAudio(for: spaceship)
                spaceshipAudio.play()

                spaceship.components.set(ShipControlComponent(parameters: .init()))
                spaceship.components.set(ShipFlightComponent())
                spaceship.components.set(ShipVisualsComponent())
                spaceship.components.set(ShipAudioComponent())
                spaceship.components.set(
                    ClosureComponent { _ in
                        if
                            let localThrottle = spaceship.components[ThrottleComponent.self],
                            let localPitchRoll = spaceship.components[PitchRollComponent.self]
                        {
                            throttle = localThrottle.throttle
                            pitch = localPitchRoll.pitch
                            roll = localPitchRoll.roll
                        }
                    }
                )

                spaceship.position = [0, 1, -0.75]
                content.add(spaceship)

                if let throttleDisplay = attachments.entity(for: Self.throttleDisplayId) {
                    throttleDisplay.components.set(ThrottleLabelPlacementComponent())
                    throttleDisplay.components.set(BillboardComponent())
                    content.add(throttleDisplay)
                }
                if let pitchRollDisplay = attachments.entity(for: Self.pitchRollDisplayId) {
                    pitchRollDisplay.components.set(PitchRollLabelPlacementComponent())
                    pitchRollDisplay.components.set(BillboardComponent())
                    content.add(pitchRollDisplay)
                }

#if os(visionOS) && !targetEnvironment(simulator)
                HandsShipControlProviderSystem.registerSystem()
                content.add(Entity.makeHandTrackingEntities())
#endif
                ShipControlSystem.registerSystem()
            } catch {
                print("❌ Could not load spaceship. Error=\(error).")
            }
        } attachments: {
            Attachment(id: Self.throttleDisplayId) {
                VStack {
                    let throttleDisplay = Int(throttle * 100)
                    Text("Throttle: \(throttleDisplay)%")
                }
                .flightSchoolLabelStyle()
            }

            Attachment(id: Self.pitchRollDisplayId) {
                VStack {
                    let pitchDisplay = Int(Angle(radians: Double(pitch)).degrees)
                    let rollDisplay = Int(Angle(radians: Double(roll)).degrees)

                    Text("Pitch: \(pitchDisplay)º")
                    Text("Roll: \(rollDisplay)º")
                }
                .flightSchoolLabelStyle()
            }
        }
    }
}

struct FlightSchoolLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.title)
            .monospacedDigit()
    }
}

extension View {
    func flightSchoolLabelStyle() -> some View {
        modifier(FlightSchoolLabelModifier())
    }
}
#endif // os(visionOS)
