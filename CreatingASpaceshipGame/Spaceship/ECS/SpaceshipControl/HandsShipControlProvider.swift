/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Component and System for hand tracking based spaceship control.
*/

#if os(visionOS)

import RealityKit

struct HandTrackingComponent: Component {
    enum Location: String {
        case leftIndexFingerTip, leftThumbTip, leftPalm, rightPalm
    }

    let location: HandTrackingComponent.Location
}

struct ThrottleLabelPlacementComponent: Component {
    init() {
        ThrottleLabelPlacementComponent.registerComponent()
    }

    func computeTransformWith(indexTipTransform: float4x4,
                              thumbTipTransform: float4x4) -> float4x4 {
        let midPosition = (indexTipTransform.translation + thumbTipTransform.translation) * 0.5
        let offset = SIMD3<Float>(0, 0.1, 0)
        let position = midPosition + offset
        return float4x4(translation: position)
    }
}

struct PitchRollLabelPlacementComponent: Component {
    init() {
        PitchRollLabelPlacementComponent.registerComponent()
    }

    func computeTransformWith(rightPalmTransform: float4x4) -> float4x4 {
        let offset = SIMD3<Float>(0, 0.1, 0)
        let position = rightPalmTransform.translation + offset
        return float4x4(translation: position)
    }
}

final class HandsShipControlProviderSystem: System {

    static var dependencies: [SystemDependency] = [.before(ShipControlSystem.self)]
    
    static let pitchRollLabelQuery = EntityQuery(where: .has(PitchRollLabelPlacementComponent.self))
    
    let session = SpatialTrackingSession()

    init(scene: Scene) {
        HandTrackingComponent.registerComponent()

        Task { @MainActor in
            let config = SpatialTrackingSession.Configuration(tracking: [.hand])
            
            _ = await session.run(config)
        }
    }

    func update(context: SceneUpdateContext) {
        // Store anchor transforms.
        var transforms: [HandTrackingComponent.Location: simd_float4x4] = [:]

        for entity in context.entities(matching: EntityQuery(where: .has(HandTrackingComponent.self)), updatingSystemWhen: .rendering) {
            guard let anchorEntity = entity as? AnchorEntity,
                  anchorEntity.isAnchored else {
                continue
            }

            guard let handTrackingComponent = entity.components[HandTrackingComponent.self] else { continue }

            transforms[handTrackingComponent.location] = entity.transformMatrix(relativeTo: nil)
        }

        // Update `ThrottleLabelPlacementComponent`.
        if let indexTipTransform = transforms[.leftIndexFingerTip],
           let thumbTipTransform = transforms[.leftThumbTip] {

            for entity in context.entities(matching: EntityQuery(where: .has(ThrottleLabelPlacementComponent.self)), updatingSystemWhen: .rendering) {
                guard let component = entity.components[ThrottleLabelPlacementComponent.self] else { continue }
                let transform = component.computeTransformWith(indexTipTransform: indexTipTransform,
                                                               thumbTipTransform: thumbTipTransform)
                entity.interpolate(towards: transform, smoothingFactor: 0.1)
            }
        }

        // Update `PitchRollLabelPlacementComponent`.
        if let rightPalmTransform = transforms[.rightPalm] {
            for entity in context.entities(matching: HandsShipControlProviderSystem.pitchRollLabelQuery, updatingSystemWhen: .rendering) {
                guard let component = entity.components[PitchRollLabelPlacementComponent.self] else { continue }
                let transform = component.computeTransformWith(rightPalmTransform: rightPalmTransform)
                entity.interpolate(towards: transform, smoothingFactor: 0.1)
            }
        }

        // Update the ship controls with hand tracking.
        for entity in context.entities(matching: EntityQuery(where: .has(ShipControlComponent.self)), updatingSystemWhen: .rendering) {
            updateShipControlParameters(for: entity, context: context, transforms: transforms)
        }
    }
    
    func updateShipControlParameters(for entity: Entity, context: SceneUpdateContext, transforms: [HandTrackingComponent.Location: simd_float4x4]) {
        let shipControlParameters = entity.components[ShipControlComponent.self]!.parameters
        let currentThrottle = shipControlParameters.throttle

        guard let indexTipTransform = transforms[.leftIndexFingerTip],
              let thumbTipTransform = transforms[.leftThumbTip] else {
            print("⚠️ Lost tracking of left hand. Disabling throttle.")
            shipControlParameters.throttle = interpolateThrottle(current: currentThrottle,
                                                                 target: .zero,
                                                                 deltaTime: context.deltaTime)
            return
        }

        let targetThrottle = computeTargetThrottle(indexTipTransform: indexTipTransform,
                                                   thumbTipTransform: thumbTipTransform)

        shipControlParameters.throttle = interpolateThrottle(current: currentThrottle,
                                                             target: targetThrottle,
                                                             deltaTime: context.deltaTime)

        guard let leftPalmTransform = transforms[.leftPalm] else { return }
        guard let rightPalmTransform = transforms[.rightPalm] else { return }

        let (pitch, roll) = computePitchAndRoll(leftPalmTransform: leftPalmTransform,
                                                rightPalmTransform: rightPalmTransform)

        shipControlParameters.pitch = pitch
        shipControlParameters.roll = roll
    }

    func interpolateThrottle(current: Float, target: Float, deltaTime: TimeInterval) -> Float {
        let delta = target - current
        let deltaTimeScaled = Float(deltaTime) * 5
        let interpolatedThrottle = current + delta * deltaTimeScaled
        return interpolatedThrottle
    }

    func computeTargetThrottle(indexTipTransform: float4x4, thumbTipTransform: float4x4) -> Float {
        let indexTipPosition = indexTipTransform.translation
        let thumbTipPosition = thumbTipTransform.translation
        let pinchMagnitude = distance(indexTipPosition, thumbTipPosition)
        return PinchToThrottle.computeThrottle(with: pinchMagnitude)
    }

    func computePitchAndRoll(leftPalmTransform: float4x4, rightPalmTransform: float4x4) -> (Float, Float) {
        let leftPalmPosition = leftPalmTransform.translation
        let rightPalmPosition = rightPalmTransform.translation

        let leftToRight = rightPalmPosition - leftPalmPosition

        guard leftToRight.length() > 0 else {
            // Sometimes the positions are the same and you can't compute a direction.
            return (0, 0)
        }

        let right = normalize(rightPalmPosition - leftPalmPosition)
        let worldUp = SIMD3<Float>(0, 1, 0)
        let backward = normalize(cross(right, worldUp))
        let upward = normalize(cross(backward, right))

        let midpoint = float4x4(columns: (
                SIMD4<Float>(right, 0),
                SIMD4<Float>(upward, 0),
                SIMD4<Float>(backward, 0),
                [0, 0, 0, 1]))

        // rightPalmTransform definition:
        // [1, 0, 0] is the direction from palm to wrist
        // [0, 1, 0] is the direction from palm to center of hand
        // [0, 0, 1] is the direction from palm to the opposite of thumb
        //
        // Define `handForward` as the direction from wrist to palm,
        // and `handThumb` as the direction from palm to thumb.
        let palmToWrist: SIMD4<Float> = [-1, 0, 0, 0]
        let palmToThumb: SIMD4<Float> = [0, 0, -1, 0]

        let handRelativeToMidpoint = midpoint.inverse * rightPalmTransform

        let handForward = normalize((handRelativeToMidpoint * palmToWrist).xyz)
        let handThumb = normalize((handRelativeToMidpoint * palmToThumb).xyz)

        // Project `handForward` direction to the YZ plane for controlling pitch.
        let projectToPitchPlane: SIMD3 = normalize(SIMD3(0, handForward.y, handForward.z))
        let angleFromZ: Float = atan2(projectToPitchPlane.y, projectToPitchPlane.z)

        // Convert angle from positive Z to angle from negative Z (both around negative X).
        let pitch: Float = -angleFromZ + .pi * sign(angleFromZ)

        // Project `handThumb` direction to the XY plane for controlling roll.
        let projectToRollPlane: SIMD3 = normalize(SIMD3(handThumb.x, handThumb.y, 0))
        let angleFromX: Float = atan2(projectToRollPlane.y, projectToRollPlane.x)

        // Convert angle from positive X to angle from negative X (both around positive Z).
        let roll: Float = angleFromX - .pi * sign(angleFromX)

        return (pitch, roll)
    }
}

extension Entity {
    func interpolate(towards: float4x4, smoothingFactor: Float) {
        let current = transformMatrix(relativeTo: nil)
        setTransformMatrix(current + (towards - current) * smoothingFactor, relativeTo: nil)
    }

    static func makeHandTrackingEntities() -> Entity {
        let container = Entity()
        container.name = "HandTrackingEntitiesContainer"

        let leftHand = AnchorEntity(.hand(.left, location: .palm))
        leftHand.components.set(HandTrackingComponent(location: .leftPalm))

        let rightHand = AnchorEntity(.hand(.right, location: .palm))
        rightHand.components.set(HandTrackingComponent(location: .rightPalm))

        let indexTip = AnchorEntity(.hand(.left, location: .indexFingerTip))
        indexTip.components.set(HandTrackingComponent(location: .leftIndexFingerTip))

        let thumbTip = AnchorEntity(.hand(.left, location: .thumbTip))
        thumbTip.components.set(HandTrackingComponent(location: .leftThumbTip))

        container.addChild(leftHand)
        container.addChild(rightHand)
        container.addChild(indexTip)
        container.addChild(thumbTip)

        return container
    }
}

#endif
