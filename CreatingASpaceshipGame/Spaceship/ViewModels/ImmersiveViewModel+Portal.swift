/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Portal related extensions for the ImmersiveViewModel.
*/

import RealityKit

extension ImmersiveViewModel {

    func spawnPortal() async throws {

        let portal = try await Entity.makePortalToOuterspace()
        portal.position = [0, 1, -4]
        rootEntity.addChild(portal)

        if let outerspace = portal.components[PortalComponent.self]?.targetEntity {

            var entitiesToAddToPortal: [Entity] = []

            if let spaceship = spaceship {
                entitiesToAddToPortal.append(spaceship)
            }

            if let trailer = trailer {
                entitiesToAddToPortal.append(trailer)
            }

            entitiesToAddToPortal.append(contentsOf: findCargos())

            for entity in entitiesToAddToPortal {
                entity.setParent(outerspace, preservingWorldTransform: true)
            }
        }

        astronomicalObjects?.removeFromParent()
        astronomicalObjects = nil
    }

    func prepareEntitiesForPortalCrossing() {
        var entitiesToEnablePortalCrossing: [Entity] = []

        if let spaceship = spaceship {
            entitiesToEnablePortalCrossing.append(spaceship)
        }

        if let trailer = trailer {
            entitiesToEnablePortalCrossing.append(trailer)
        }

        entitiesToEnablePortalCrossing.append(contentsOf: findCargos())

        for entity in entitiesToEnablePortalCrossing {
            entity.components.set(PortalCrossingComponent())
        }
    }
}
