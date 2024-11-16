/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The immersive view represents the 3D scene that's populated with
 the RealityKit entities created in Reality Composer Pro.
*/

import SwiftUI
import RealityKit
import RealityKitContent

// This view handles notifications from tap gestures and determines if the
// tapped entity is an unhealthy hero plant. If the entity is an unhealthy
// hero plant, and if the hero robot is available to help, then this view sends
// the robot to the unhealthy plant.
struct ImmersiveView: View {

    @Environment(AppModel.self) var appModel
    @Environment(\.scenePhase) private var scenePhase

    private let notificationTrigger = NotificationCenter.default.publisher(for: Notification.Name("RealityKit.NotificationTrigger"))

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content.
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
        }
        .gesture(TapGesture().targetedToAnyEntity()
            .onEnded({ value in
                // Ensure the tapped entity is a hero plant and that it needs tending.
                if let scene = value.entity.scene,
                   let heroRobot = getHeroRobotIfAvailable(scene: scene),
                   isPlantUnhealthy(entity: value.entity),
                   heroRobot.components[HeroRobotRuntimeComponent.self] != nil {
                    heroRobot.components[HeroRobotRuntimeComponent.self]?.setState(newState: .moving)
                    // Apply the tap behaviors on the entity.
                    _ = value.entity.applyTapForBehaviors()
                }
            })
        )
        .onChange(of: scenePhase) { _, newPhase in
            Task { @MainActor in
                if newPhase == .background {
                    appModel.immersiveSpaceIsShown = false
                    appModel.showImmersiveSpace = false
                }
            }
        }
        .onReceive(notificationTrigger) { output in
            guard let entity = output.userInfo?["RealityKit.NotificationTrigger.SourceEntity"] as? Entity,
                  let notificationName = output.userInfo?["RealityKit.NotificationTrigger.Identifier"] as? String,
                  let heroRobot = getHeroRobot(from: entity.scene) else { return }

            switch notificationName {
            case .reachToPoppyNotification:
                heroRobot.components[HeroRobotRuntimeComponent.self]?.setState(newState: .beginReach, targetPlantName: "hero_poppy")
            case .reachToCoffeeBerryNotification:
                heroRobot.components[HeroRobotRuntimeComponent.self]?.setState(newState: .beginReach, targetPlantName: "hero_coffeeBerry")
            case .reachToYuccaNotification:
                heroRobot.components[HeroRobotRuntimeComponent.self]?.setState(newState: .beginReach, targetPlantName: "hero_yucca")
            case .startWateringNotification:
                heroRobot.components[HeroRobotRuntimeComponent.self]?.setState(newState: .beginWatering)
            case .stopWateringNotification:
                heroRobot.components[HeroRobotRuntimeComponent.self]?.setState(newState: .stopWatering)
            case .returnHomeNotification:
                heroRobot.components[HeroRobotRuntimeComponent.self]?.setState(newState: .beginReturnHome)
            default:
                return
            }
        }
    }

    // MARK: Helpers
    private func getHeroRobotIfAvailable(scene: RealityFoundation.Scene) -> Entity? {
        if let heroRobot = scene.findEntity(named: "hero_robot"),
           let heroRobotComponent = heroRobot.components[HeroRobotRuntimeComponent.self],
           heroRobotComponent.isAvailable() {
            return heroRobot
        }

        return nil
    }

    private func getHeroRobot(from scene: RealityFoundation.Scene?) -> Entity? {
        guard let heroRobot = scene?.findEntity(named: "hero_robot"),
              heroRobot.components[HeroRobotRuntimeComponent.self] != nil else {
            return nil
        }

        return heroRobot
    }

    private func isPlantUnhealthy(entity: Entity) -> Bool {
        // Check for the HeroPlantRuntimeComponent on the entities children.
        if let plantWithComponent = entity.children.first(where: { $0.components[HeroPlantRuntimeComponent.self] != nil }) {
            let plantComponent = plantWithComponent.components[HeroPlantRuntimeComponent.self]
            return plantComponent?.needsTending() ?? false
        }

        // Search up the hierarchy until you find `nil` or an entity with the
        // `HeroPlantRuntimeComponent` on it.
        var entityToCheck = entity
        var heroPlantComponent = entityToCheck.components[HeroPlantRuntimeComponent.self]

        while heroPlantComponent == nil {
            if let newParent = entityToCheck.parent {
                entityToCheck = newParent
                heroPlantComponent = newParent.components[HeroPlantRuntimeComponent.self]
            } else {
                break
            }
        }

        return heroPlantComponent?.needsTending() ?? false
    }

}

private extension String {
    static let reachToPoppyNotification = "ReachToPoppy"
    static let reachToCoffeeBerryNotification = "ReachToCoffeeBerry"
    static let reachToYuccaNotification = "ReachToYucca"
    static let startWateringNotification = "StartWatering"
    static let stopWateringNotification = "StopWatering"
    static let returnHomeNotification = "ReturnHome"
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
