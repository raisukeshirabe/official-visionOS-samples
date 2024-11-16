/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The methods that create each pendulum's entities and model components.
*/

import RealityKit

extension MainView {
    /// Creates a new ball entity with only a model component, no physics components.
    func makeBallEntity() -> Entity {
        let ballEntity = Entity()
        ballEntity.name = "ball"

        // Create a mesh and material for the ball.
        let ballMesh = MeshResource.generateSphere(radius: pendulumSettings.ballRadius)
        let ballMaterial = SimpleMaterial(color: .lightGray, isMetallic: true)

        // Create and apply the model component.
        let modelComponent = ModelComponent(
            mesh: ballMesh, materials: [ballMaterial])
        ballEntity.components.set(modelComponent)

        // Position the ball at the string's length down.
        ballEntity.position.y = -pendulumSettings.stringLength

        return ballEntity
    }

    /// Creates a new string entity with only a model component, no physics components.
    func makeStringEntity() -> Entity {
        let stringEntity = Entity()

        // Create a mesh and material for the string.
        let stringMesh = MeshResource.generateCylinder(
            height: pendulumSettings.stringLength,
            radius: pendulumSettings.stringRadius
        )
        var stringMaterial = PhysicallyBasedMaterial()
        stringMaterial.baseColor.tint = pendulumSettings.stringColor

        // Create and apply the model component.
        let stringModel = ModelComponent(mesh: stringMesh, materials: [stringMaterial])
        stringEntity.components.set(stringModel)

        // Position the string halfway between the ball and the attachment.
        stringEntity.position.y = pendulumSettings.stringLength / 2

        return stringEntity
    }

    /// Creates a new attachment entity with only a model component, no physics components.
    func makeAttachmentEntity() -> Entity {
        let attachmentEntity = Entity()
        attachmentEntity.name = "attachment"

        // Create a mesh and material for the attachment.
        let attachmentMesh = MeshResource.generateBox(
            size: pendulumSettings.attachmentSize * pendulumSettings.ballRadius
        )
        var attachmentMaterial = PhysicallyBasedMaterial()
        attachmentMaterial.baseColor.tint = pendulumSettings.attachmentColor

        // Create and apply the model component.
        let attachmentModel = ModelComponent(mesh: attachmentMesh, materials: [attachmentMaterial])
        attachmentEntity.components.set(attachmentModel)

        return attachmentEntity
    }
}
