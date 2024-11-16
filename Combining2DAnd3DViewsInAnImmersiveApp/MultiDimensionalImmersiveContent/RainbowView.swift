/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Creates attachments and adds all entities and attachments to a `RealityView`.
*/

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor struct RainbowView: View {
    // MARK: - Properties
    @State private var rainbowModel = RainbowModel()
    
    /// The root entity for the scene.
    private let root = Entity()
    
    @Environment(\.physicalMetrics) private var physicalMetrics
    
    var body: some View {
        RealityView { content, attachments in
            root.name = "root"
            // Create the plane entity.
            let planeEntity = await createEntity(for: rainbowModel.plane)
            
            // Add the plane as a subentity of the root.
            root.addChild(planeEntity)
            
            // Iterate over the green and yellow arches, which load through Reality Composer Pro.
            for (index, item) in rainbowModel.realityKitAssets.enumerated() {
                
                // Create the entity and set necessary components.
                let entity = await createEntity(for: item)
                await configureForTapGesture(entity: entity)
                
                // Add each entity to the root.
                planeEntity.addChild(entity)
                
                // Set the position to be 0.3 behind the first entity.
                // Add 0.4 so the model sits farther up on the grass.
                entity.position.z = Float(-0.3 * Double(index) + 0.4)
            }
            // Set the position of the root and the plane.
            root.position = [0, 1, -3]
            planeEntity.setPosition([0, 0, 0], relativeTo: root)
            
            // Scale the plane entity and its subentities to be taller.
            planeEntity.scale.y *= 1.2
            
            // Add all attachments and position them.
            addAttachments(attachments: attachments)
            
            content.add(root)
        } update: { content, attachments in
            guard let root = content.entities.first else { return }
            if let clearButtonAttachment = attachments.entity(for: "clear") {
                clearButtonAttachment.name = "clear"
                root.addChild(clearButtonAttachment)
                
                clearButtonAttachment.setPosition([0, 0.1, 1.4], relativeTo: root)
            }
            
            for cloud in rainbowModel.tapAttachments {
                if let cloudEntity = attachments.entity(for: cloud.position) {
                    // Scale the attachment larger and add it.
                    cloudEntity.scale = [5, 5, 5]
                    cloudEntity.name = "\(cloud.position)tapEntity"
                    root.addChild(cloudEntity)
                    
                    // Set the position of the attachment.
                    cloudEntity.setPosition(cloud.position, relativeTo: cloud.parent)
                }
            }
        } attachments: {
            // MARK: - Attachments closure
            // Iterate over the attachments array and create the various arches.
            ForEach(rainbowModel.archAttachments) { entity in
                // Create an attachment with an ID that the `update` closure references.
                Attachment(id: "\(entity.title.rawValue)ArchAttachmentEntity") {
                    createArchAttachment(for: entity.title)
                        .clipShape(Arc(centerAngle: .degrees(-90)))
                        .contentShape(.hoverEffect, Arc(centerAngle: .degrees(-90)))
                        .hoverEffect { effect, isActive, _ in
                            effect.opacity(isActive ? 0.6 : 1)
                        }
                        .gesture(
                            SpatialTapGesture(coordinateSpace: .immersiveSpace)
                                .onEnded { value in
                                    createAndPositionTapEntity(tapLocation: value.location3D, color: entity.title)
                                }
                        )
                }
            }
            
            // Create a Clear button.
            Attachment(id: "clear") {
                Button("Remove clouds") {
                    // Remove all clouds.
                    root.children.removeAll(where: { $0.name.contains("tapEntity") })
                    rainbowModel.tapAttachments = []
                }
                .padding()
                .glassBackgroundEffect()
            }
            
            // Iterate over the tap attachments and provide content for each.
            ForEach(rainbowModel.tapAttachments) { cloud in
                Attachment(id: cloud.position) {
                    Image(systemName: "cloud.fill")
                }
            }
        }
        .simultaneousGesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Convert the tap location to the scene's coordinate space.
                    var location3D = value.convert(value.location3D, from: .local, to: .scene)
                    // Move the z index forward to ensure it doesn't overlap with the entity.
                    location3D.z += 0.02
                    
                    // You don't need to set the position of attachments on entities relative to the root entity, so pass `nil` here.
                    // The system handles this with the location conversion.
                    rainbowModel.tapAttachments.append(CloudTapAttachment(position: location3D, parent: nil))
                }
        )
    }
}
    
extension RainbowView {
    
    /// Performs the necessary steps to add and position attachments in the scene.
    /// - Parameter attachments: The attachments to add to the scene.
    func addAttachments(attachments: RealityViewAttachments) {
        // Find entities from the scene necessary for positioning the attachments.
        let plane = root.findEntity(named: "plane")
        let yellowArch = root.findEntity(named: "yellow")
        
        // Find the visual bounds of the model entity.
        let yellowBounds = yellowArch?.findEntity(named: "yellow")!.visualBounds(relativeTo: plane)
        
        // Get the entities, scales, and positions to add as attachments.
        scaleAndPositionArches(yellowArchSize: yellowBounds ?? BoundingBox())
        
        // Add and configure attachments.
        for viewAttachmentEntity in rainbowModel.archAttachments {
            
            // Check whether there's an attachment.
            if let attachment = attachments.entity(for: "\(viewAttachmentEntity.title)ArchAttachmentEntity") {
                
                attachment.name = viewAttachmentEntity.title.rawValue
                
                // Add it as a subentity of the plane.
                plane?.addChild(attachment)
                
                // Set the scale and position.
                attachment.scale = viewAttachmentEntity.scale
                attachment.setPosition(viewAttachmentEntity.position, relativeTo: yellowArch)
            }
        }
    }
    
    /// Creates the arch view for each attachment based on the color.
    @ViewBuilder func createArchAttachment(for arch: ArchAttachmentColor) -> some View {
            switch arch {
            case .blue:
                SwiftUIArcView(color: .blue)
            case .orange:
                UIViewArcViewRep(color: .orange)
            case .pink:
                SwiftUIArcView(color: .pink)
            case .red:
                CALayerArcViewRep(color: .red)
        }
    }
    
    /// Creates an attachment when someone taps an entity, converts the position to meters, and then positions the entity.
    func createAndPositionTapEntity(tapLocation: Point3D, color: ArchAttachmentColor) {
        // Get the root entity and attachment.
        guard
            let plane = root.children.first(where: { $0.name == "plane" }),
            let attachment = plane.children.first(where: { $0.name == "\(color.rawValue)" })
        else { return }
        
        // Convert the tap location to meters from the SwiftUI window's coordinates.
        let immersiveSpaceLocation = physicalMetrics.convert(tapLocation, to: .meters)
        let position = SIMD3(x: Float(immersiveSpaceLocation.x), y: -Float(immersiveSpaceLocation.y), z: Float(immersiveSpaceLocation.z))
        rainbowModel.tapAttachments.append(CloudTapAttachment(position: position, parent: attachment))
    }
    
    /// Updates the array containing the scale and position for each attachment entity.
    func scaleAndPositionArches(yellowArchSize: BoundingBox) {
        // MARK: - Scaling properties
        
        // Set the x scale to be the same as the yellow arch.
        // Set the y scale to be double the yellow arch to account for the larger frame due to the SwiftUI view.
        var archScale = SIMD3(x: yellowArchSize.extents.x, y: yellowArchSize.max.y * 2, z: 1)
        
        // MARK: - Positioning properties
        
        // Set the y position to be the same as the yellow arch.
        let yPosition = yellowArchSize.min.y
        
        // Set the z position to be 0.1 meters back.
        var zPosition: Float = -0.1
        var position = SIMD3(x: 0, y: yPosition, z: zPosition)
        
        for (index, attachment) in rainbowModel.archAttachments.enumerated() {
            
            // Push the arch back by 0.1 meters.
            zPosition -= 0.1
            position.z = zPosition
            
            // Update the attachments in the view attachment array to include position and scale.
            rainbowModel.archAttachments[index] = ArchAttachment(title: attachment.title, position: position, scale: archScale)
            
            // Scale the next attachment to be 75% of the size of the previous arch.
            archScale *= 3 / 4
        }
    }
    
    /// Creates an entity from the data model for each Reality Composer Pro asset.
    func createEntity(for item: EntityData) async -> Entity {
        
        // Load the entity from Reality Composer Pro.
        let realityComposerEntity = try! await Entity(named: item.title, in: realityKitContentBundle)
        
        // Find the model component entity and model component.
        guard
            let modelEntity = realityComposerEntity.findEntity(named: item.title),
            var modelComponent = modelEntity.components[ModelComponent.self]
        else {
            return Entity()
        }
        
        // Set the material if it has a simple material.
        if let material = item.simpleMaterial {
            modelComponent.materials = [material]
        }
        
        // Set the model component.
        modelEntity.components.set(modelComponent)
        
        return modelEntity
    }
    
    /// Sets the components necessary for hover and tap gestures.
    func configureForTapGesture(entity: Entity) async {
        // Set the hover effect component.
        entity.components.set(HoverEffectComponent())
        
        // Find the `ModelComponent` to get the mesh and create a static mesh in the shape of the entity.
        guard let modelComponent = entity.components[ModelComponent.self] else { return }
        let entityMesh = modelComponent.mesh
        let shapeResource = try! await ShapeResource.generateStaticMesh(from: entityMesh)
        entity.components.set(CollisionComponent(shapes: [shapeResource]))
        
        // Set the input target component.
        entity.components.set(InputTargetComponent())
    }
}
