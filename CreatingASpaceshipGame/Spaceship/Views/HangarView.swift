/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Hangar view where player interacts with the spaceship through UI and drag gesture.
*/

import SwiftUI
import RealityKit

struct HangarView: View {

    @State var yaw: Float = .pi / 2
    @State var pitch: Float = 0

    @State private var isPlayingVaporTrail = false
    @State private var isPlayingExhaust = false
    @State private var isPlayingTurbine = false

    @State private var viewModel = HangarViewModel()

#if os(visionOS)
    var body: some View {
        VStack {
            Spacer()

            RealityView { content, attachments in
                guard let hangarView = attachments.entity(for: "HangarView") else {
                    return
                }
                hangarView.position += [0, -0.038, 0.25]
                content.add(hangarView)
            } attachments: {
                Attachment(id: "HangarView") {
                    VStack {
                        throttleSlider
                        engineSubpartControls
                    }
                    .frame(maxWidth: 400)
                    .padding(20)
                    .glassBackgroundEffect()
                }
            }

            SpaceshipView(yaw: yaw, pitch: pitch, viewModel: viewModel)
                .dragRotation(yaw: $yaw, pitch: $pitch, pitchLimit: .degrees(45), sensitivity: 5)
                .frame(width: 1000, height: 200)
                .frame(depth: 1000)
        }
    }
#elseif os(iOS)
    var body: some View {
        ZStack {
            SpaceshipView(yaw: yaw, pitch: pitch, viewModel: viewModel)
                .dragRotation(yaw: $yaw, pitch: $pitch, pitchLimit: .degrees(45), sensitivity: 5)

            VStack {
                throttleSlider
                engineSubpartControls
            }
            .frame(width: 200)
            .padding(20)
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 20))
            .anchorToTopRight()
        }
    }
#endif

    var throttleSlider: some View {
        VStack {
            HStack {
                Text("Throttle")
                    .bold()
                Spacer()
                Text(viewModel.throttle, format: .number.precision(.fractionLength(2)))
                    .monospacedDigit()
            }

            Slider(value: $viewModel.throttle, in: 0...1)
        }
    }

    var engineSubpartControls: some View {
        VStack {
            Toggle("Vapor Trail", isOn: $isPlayingVaporTrail)
                .onChange(of: isPlayingVaporTrail) {
                    for controller in viewModel.spaceshipAudio.vaporTrailControllers.values {
                        isPlayingVaporTrail ? controller.play() : controller.stop()
                    }
                }

            Toggle("Exhaust", isOn: $isPlayingExhaust)
                .onChange(of: isPlayingExhaust) {
                    for controller in viewModel.spaceshipAudio.exhaustControllers.values {
                        isPlayingExhaust ? controller.playAndFadeIn(duration: 2) : controller.stop()
                    }
                }

            Toggle("Turbine", isOn: $isPlayingTurbine)
                .onChange(of: isPlayingTurbine) {
                    for controller in viewModel.spaceshipAudio.turbineControllers.values {
                        isPlayingTurbine ? controller.play() : controller.stop()
                    }
                }
        }
    }
}

struct SpaceshipView: View, Animatable {

    var yaw: Float
    var pitch: Float

    var animatableData: AnimatablePair<Float, Float> {
        get {
            .init(yaw, pitch)
        }
        set {
            yaw = newValue.first
            pitch = newValue.second
        }
    }

    var viewModel: HangarViewModel

    var body: some View {
        RealityView { content in
            do {
                let spaceship = try await viewModel.prepareSpaceship()

                // Make the spaceship interactable with a drag gesture.
                spaceship.components.set(InputTargetComponent())
                spaceship.components.set(HoverEffectComponent(.shader(.default)))
#if os(visionOS)
                spaceship.scale *= 1.5
                spaceship.position.y -= 0.07
#elseif os(iOS)
                spaceship.scale *= 1.5
                spaceship.position.y -= 0.2
                spaceship.position.z -= 0.3

                await content.setupWorldTracking()
                content.camera = .spatialTracking
#endif
                content.add(spaceship)
            } catch {
                print("Could not load spaceship. Error=\(error).")
            }
        } update: { content in
            viewModel.spaceship?.transform.rotation = .init(angle: pitch, axis: .left) *
                                                      .init(angle: yaw, axis: .upward)

            viewModel.spaceship?.components[ThrottleComponent.self]!.throttle = Float(viewModel.throttle)
        }
#if os(visionOS)
        .frame(width: 300, height: 200)
        .offset(z: 100)
#endif
    }
}

extension View {
    /// Enables people to drag an entity to rotate it, with optional limitations
    /// on the rotation in yaw and pitch.
    func dragRotation(
        yaw: Binding<Float>,
        pitch: Binding<Float>,
        yawLimit: Angle? = nil,
        pitchLimit: Angle? = nil,
        sensitivity: Float = 10,
        axRotateClockwise: Bool = false,
        axRotateCounterClockwise: Bool = false
    ) -> some View {
        modifier(
            DragRotationModifier(
                yaw: yaw,
                pitch: pitch,
                yawLimit: yawLimit,
                pitchLimit: pitchLimit,
                sensitivity: sensitivity,
                axRotateClockwise: axRotateClockwise,
                axRotateCounterClockwise: axRotateCounterClockwise,
                baseYaw: yaw.wrappedValue,
                basePitch: pitch.wrappedValue
            )
        )
    }
}

/// A modifier converts drag gestures into entity rotation.
private struct DragRotationModifier: ViewModifier {
    @Binding var yaw: Float
    @Binding var pitch: Float

    var yawLimit: Angle?
    var pitchLimit: Angle?

    var sensitivity: Float
    var axRotateClockwise: Bool
    var axRotateCounterClockwise: Bool

    @State var baseYaw: Float
    @State var basePitch: Float

    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: 0.0)
                .targetedToAnyEntity()
                .onChanged { value in
                    // Find the current linear displacement.
                    let location3D = value.locationInScene()
                    let startLocation3D = value.startLocationInScene()

                    let delta = location3D - startLocation3D

                    // Use an interactive spring animation that becomes
                    // a spring animation when the gesture ends below.
                    withAnimation(.interactiveSpring) {
                        yaw = spin(displacement: delta.x, base: baseYaw, limit: yawLimit)
                        pitch = spin(displacement: -delta.y, base: basePitch, limit: pitchLimit)
                    }
                }
                .onEnded { value in
                    // Find the current and predicted final linear displacements.
                    let location3D = value.locationInScene()
                    let startLocation3D = value.startLocationInScene()
                    let predictedEndLocation3D = value.predictedEndLocationInScene()
                    let delta = location3D - startLocation3D
                    let predictedDelta = predictedEndLocation3D - location3D

                    // Set the final spin value using a spring animation.
                    withAnimation(.spring) {
                        yaw = finalSpin(
                            displacement: delta.x,
                            predictedDisplacement: predictedDelta.x,
                            base: baseYaw,
                            limit: yawLimit)
                        pitch = finalSpin(
                            displacement: -delta.y,
                            predictedDisplacement: -predictedDelta.y,
                            base: basePitch,
                            limit: pitchLimit)
                    }

                    // Store the last value for use by the next gesture.
                    baseYaw = yaw
                    basePitch = pitch
                }
            )
            .onChange(of: axRotateClockwise) {
                withAnimation(.spring) {
                    yaw -= (.pi / 6)
                    baseYaw = yaw
                }
            }
            .onChange(of: axRotateCounterClockwise) {
                withAnimation(.spring) {
                    yaw += (.pi / 6)
                    baseYaw = yaw
                }
            }
    }

    /// Finds the spin for the specified linear displacement, subject to an
    /// optional limit.
    private func spin(
        displacement: Float,
        base: Float,
        limit: Angle?
    ) -> Float {
        if let limit {
            return atan(displacement * sensitivity) * Float(limit.degrees / 90)
        } else {
            return base + displacement * sensitivity
        }
    }

    /// Finds the final spin given the current and predicted final linear
    /// displacements, or zero when restricting the spin.
    private func finalSpin(
        displacement: Float,
        predictedDisplacement: Float,
        base: Float,
        limit: Angle?
    ) -> Float {
        // If there is a spin limit, always return to zero spin at the end.
        guard limit == nil else { return 0 }

        // Find the projected final linear displacement, capped at 1 more revolution.
        let cap = .pi * 2.0 / sensitivity
        let delta = displacement + max(-cap, min(cap, predictedDisplacement))

        // Find the final spin.
        return base + delta * sensitivity
    }

}

extension EntityTargetValue<DragGesture.Value> {
    func locationInScene() -> SIMD3<Float> {
#if os(visionOS)
        return convert(self.location3D, from: .local, to: .scene)
#elseif os(iOS)
        if let (origin, direction) = ray(through: self.location, in: .local, to: .scene) {
           return origin + length(entity.position - origin) * direction
        }
        return .zero
#endif
    }

    func startLocationInScene() -> SIMD3<Float> {
#if os(visionOS)
        return convert(self.startLocation3D, from: .local, to: .scene)
#elseif os(iOS)
        if let (origin, direction) = ray(through: self.startLocation, in: .local, to: .scene) {
           return origin + length(entity.position - origin) * direction
        }
        return .zero
#endif
    }

    func predictedEndLocationInScene() -> SIMD3<Float> {
#if os(visionOS)
        return convert(self.predictedEndLocation3D, from: .local, to: .scene)
#elseif os(iOS)
        if let (origin, direction) = ray(through: self.predictedEndLocation, in: .local, to: .scene) {
           return origin + length(entity.position - origin) * direction
        }
        return .zero
#endif
    }
}

