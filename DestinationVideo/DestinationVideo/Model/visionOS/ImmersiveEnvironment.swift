/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The model that manages the environment.
*/

import SwiftUI
import RealityKit
import Studio

///  The model that manages the environment.
@MainActor @Observable class ImmersiveEnvironment {

    /// A Boolean value that indicates whether the app is presenting an immersive space.
    public var immersiveSpaceIsShown: Bool = false

    /// A Boolean value that indicates whether to open an immersive space.
    public var showImmersiveSpace: Bool = false

    /// An object that handles the state of an environment opened in an immersive space.
    private var environmentStateHandler = EnvironmentStateHandler()

    /// The state to set an environment to after it finishes loading.
    private var requestedEnvironmentState: EnvironmentStateType = .light

    public var contentBrightness: ImmersiveContentBrightness {
        switch requestedEnvironmentState {
        case .light: .dim
        case .dark: .dark
        case .none: .automatic
        }
    }

    public var surroundingsEffect: SurroundingsEffect? {
        switch requestedEnvironmentState {
        case .light: .colorMultiply(Color(red: 1.15, green: 1.2, blue: 1.4))
        case .dark: .colorMultiply(Color(red: 0.13, green: 0.12, blue: 0.09))
        case .none: nil
        }
    }

    public private(set) var rootEntity: Entity?

    public func loadEnvironment() {
        Task {
            do {
                let entity = try await Entity(named: "AAA_MainScene", in: studioBundle)
                environmentStateHandler.gatherEntities(from: entity)
                setEnvironmentState(requestedEnvironmentState)

                showImmersiveSpace = true
                rootEntity = entity
            } catch {
                logger.error("Failed to load Studio bundle: \(error.localizedDescription)")

                showImmersiveSpace = false
                rootEntity = nil
            }
        }
    }

    public func clearEnvironment() {
        environmentStateHandler.clear()
        rootEntity = nil
    }

    public func requestEnvironmentState(_ state: EnvironmentStateType) {
        guard state != .none else {
            logger.warning("Requested environment state can not be set to none")
            return
        }
        requestedEnvironmentState = state
    }

    private func setEnvironmentState(_ state: EnvironmentStateType) {
        guard state != .none else {
            logger.warning("Environment state can not be set to none")
            return
        }
        environmentStateHandler.setActiveState(state)

        switch state {
        case .light:
            setVirtualEnvironmentProbeComponent(blendParam: EnvironmentStateHandler.lightStateBlendParam)
        case .dark:
            setVirtualEnvironmentProbeComponent(blendParam: EnvironmentStateHandler.darkStateBlendParam)
        default:
            break
        }
    }

    private func findCommonEntityByName(_ name: String) -> Entity? {
        environmentStateHandler.commonEntity?.children.first(where: { $0.name == name })
    }

    private func setVirtualEnvironmentProbeComponent(blendParam: Float) {
        let virtualEnvironmentProbeEntityName = "EnvironmentProbe"

        guard let virtualEnvironmentProbeEntity = findCommonEntityByName(virtualEnvironmentProbeEntityName) else {
            logger.warning("\(virtualEnvironmentProbeEntityName) not found")
            return
        }

        if var probeComponent = virtualEnvironmentProbeEntity.components[VirtualEnvironmentProbeComponent.self] {
            if case VirtualEnvironmentProbeComponent.Source.blend(let firstProbe, let secondProbe, _) = probeComponent.source {
                probeComponent.source = .blend(from: firstProbe, to: secondProbe, t: blendParam)
                virtualEnvironmentProbeEntity.components[VirtualEnvironmentProbeComponent.self] = probeComponent
            }
        }
    }
}
