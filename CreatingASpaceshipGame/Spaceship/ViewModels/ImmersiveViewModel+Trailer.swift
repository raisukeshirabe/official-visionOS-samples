/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Trailer related extensions for the ImmersiveViewModel.
*/

import RealityKit
import RealityKitContent

extension ImmersiveViewModel {

    func addTrailer() async throws {

        guard let spaceship, trailer == nil else { return }

        let trailerRoot = try await Entity(named: "TrailerAssembly", in: realityKitContentBundle)

        guard
            let trailer = trailerRoot.findEntity(named: "Trailer"),
            let trailerGeometry = trailer.findEntity(named: "geometry"),
            let cargo = trailerRoot.findEntity(named: "Cargo")
        else {
            return
        }

        cargo.isEnabled = false

        rootEntity.addChild(trailerRoot)
        trailerRoot.components.set(AudioMaterialComponent(material: .plastic))

        if let joint = trailerJoint(spaceship: spaceship, trailerRoot: trailerRoot) {
            try joint.addToSimulation()
        }

        let collisionShapes = updateTrailerCollisionShapes(with: trailerGeometry)

        if var trailerCollision = trailer.components[CollisionComponent.self] {
            trailerCollision.shapes = collisionShapes
            trailerCollision.filter = CollisionFilter(group: .actualEarthGravity, mask: .all)
            trailer.components.set(trailerCollision)
        }

        if var trailerPhysics = trailer.components[PhysicsBodyComponent.self] {
            trailerPhysics.massProperties.mass = 1
            trailer.components.set(trailerPhysics)
        }

        cargo.isEnabled = true
        let children = Array(cargo.children)
        for child in children {
            child.setParent(rootEntity, preservingWorldTransform: true)
            child.components.set(CargoComponent())
            child.components.set(AudioMaterialComponent(material: .plastic))

            if var collision = child.components[CollisionComponent.self] {
                collision.filter = CollisionFilter(group: .actualEarthGravity, mask: .all)
                child.components.set(collision)
            }
        }

        trailer.fadeOpacity(from: 0, to: 1, duration: 2)
        self.trailer = trailer
    }
    
    func trailerJoint(spaceship: Entity, trailerRoot: Entity) -> PhysicsCustomJoint? {
        guard
            let hook = spaceship.findEntity(named: "Hook"),
            let trailer = trailerRoot.findEntity(named: "Trailer")
        else {
            return nil
        }

        let hookOffset = hook.position(relativeTo: spaceship)
        trailerRoot.setPosition(hookOffset, relativeTo: spaceship)

        let spaceshipHookPin = spaceship.pins.set(named: "Hook", position: hookOffset)
        let trailerPin = trailer.pins.set(named: "Trailer", position: .zero)
        
        var joint = PhysicsCustomJoint(pin0: spaceshipHookPin, pin1: trailerPin)

        joint.angularMotionAroundX = .range(-.pi * 0.2 ... .pi * 0.2)
        joint.angularMotionAroundY = .range(-.pi * 0.2 ... .pi * 0.2)
        joint.angularMotionAroundZ = .range(-.pi * 0.2 ... .pi * 0.2)
        joint.linearMotionAlongX = .range(-0.001 ... 0.001)
        joint.linearMotionAlongY = .range(-0.001 ... 0.001)
        joint.linearMotionAlongZ = .range(-0.001 ... 0.001)

        return joint
    }

    func updateTrailerCollisionShapes(with trailerGeometry: Entity) -> [ShapeResource] {
        var collisionShapes: [ShapeResource] = []
        
        for part in trailerGeometry.children {
            guard let collision = part.components[CollisionComponent.self] else {
                continue
            }

            for shape in collision.shapes {
                let transformedShape = shape.offsetBy(
                    rotation: part.orientation(relativeTo: trailerGeometry),
                    translation: part.position(relativeTo: trailerGeometry)
                )
                collisionShapes.append(transformedShape)
            }

            part.components[CollisionComponent.self] = nil
        }
        
        return collisionShapes
    }
    
    func removeTrailer() throws {
        trailer?.removeFromParent()
        trailer = nil

        for cargo in findCargos() {
            cargo.removeFromParent()
        }
    }

    func findCargos() -> [Entity] {
        var cargos: [Entity] = []
        for child in rootEntity.children {
            if child.components[CargoComponent.self] != nil {
                cargos.append(child)
            }
        }
        return cargos
    }
}
