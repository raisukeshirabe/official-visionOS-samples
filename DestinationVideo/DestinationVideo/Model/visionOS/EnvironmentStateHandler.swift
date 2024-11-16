/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A utility class that manages the state of an environment in an immersive space.
*/

import SwiftUI
import RealityKit

/// Describes the environment state.
enum EnvironmentStateType: String {
    case light
    case dark
    case none

    var displayName: String {
        return switch self {
        case .light:
            String(localized: "Light", comment: "Label for Light environment")
        case .dark:
            String(localized: "Dark", comment: "Label for Dark environment")
        case .none:
            String(localized: "None", comment: "Label for environment that is neither dark nor light")
        }
    }

    var name: String {
        [self.rawValue.capitalized, "State"].joined()
    }
}

///  A utility class that manages the State of the Environment presented in the immersive space.
@MainActor class EnvironmentStateHandler {
    static let commonEntityName = "Common"
    static let visualEntityName = "Visual"

    static let lightStateBlendParam: Float = 0.0
    static let darkStateBlendParam: Float = 1.0

    weak public private(set) var commonEntity: Entity?
    weak public private(set) var lightStateEntity: Entity?
    weak public private(set) var darkStateEntity: Entity?

    public private(set) var activeState: EnvironmentStateType = .none

    public func gatherEntities(from rootEntity: Entity?) {
        clear()
        guard var entity = rootEntity else { return }

        // Traverse the hierarchy until multiple children are found.
        while entity.children.count == 1 {
            entity = entity.children.first!
        }

        for childEntity in entity.children {
            let entityName = childEntity.name.lowercased()

            if entityName.contains(EnvironmentStateType.light.name.lowercased()) {
                lightStateEntity = childEntity
            } else if entityName.contains(EnvironmentStateType.dark.name.lowercased()) {
                darkStateEntity = childEntity
            } else if entityName.contains(Self.commonEntityName.lowercased()) {
                commonEntity = childEntity
            }
        }
    }

    public func setActiveState(_ state: EnvironmentStateType) {
        guard state != activeState else { return }

        guard state != .none else {
            logger.error("Active environment state can't be set to none")
            return
        }

        switch state {
        case .light:
            guard lightStateEntity != nil else {
                logger.error("Entity for light state not found, active state not changed")
                return
            }
            lightStateVisualEntity?.isEnabled = true
            darkStateVisualEntity?.isEnabled = false
            activeState = .light
        case .dark:
            guard darkStateEntity != nil else {
                logger.error("Entity for dark state not found, active state not changed")
                return
            }
            lightStateVisualEntity?.isEnabled = false
            darkStateVisualEntity?.isEnabled = true
            activeState = .dark
        default:
            break
        }
    }

    public func clear() {
        lightStateEntity = nil
        darkStateEntity = nil
        commonEntity = nil
        activeState = .none
    }

    private func getFirstChildByName(entity: Entity?, name: String) -> Entity? {
        entity?.children.first(where: { $0.name == name })
    }

    public var lightStateVisualEntity: Entity? {
        getFirstChildByName(entity: lightStateEntity, name: Self.visualEntityName)
    }

    public var darkStateVisualEntity: Entity? {
        getFirstChildByName(entity: darkStateEntity, name: Self.visualEntityName)
    }
}
