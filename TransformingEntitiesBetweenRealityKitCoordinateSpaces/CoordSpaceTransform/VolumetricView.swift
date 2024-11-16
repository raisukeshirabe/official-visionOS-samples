/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view containing the volumetric reality view.
*/

import RealityKit
import SwiftUI

/// The view that contains the contents of the volumetric window.
struct VolumetricView: View {
    
    /// The app's observable data model.
    @Environment(AppModel.self) private var appModel
    
    /// The attachment that displays the cube's translation relative to the immersive coordinate space.
    @State private var immersiveAttachmentEntity: Entity?

    var body: some View {
        createVolumetricWindowRealityView()
            .onChange(
                of: appModel.immersiveSpaceIsShown, enableImmsersiveAttachment
            )
            .onGeometryChange(
                for: AffineTransform3D.self, of: onGeometryChangeTransform,
                action: updateImmersiveSpaceTransform
            )
            .gesture(doubleTapMove)
            .gesture(appModel.dragUpdateTransforms)
            .toolbar {
                toolbarContent
            }
    }

    /// Creates the reality view for the volumetric window.
    ///
    /// The view creates the volume cube entity and the SwiftUI text showing the translation of the volume cube
    /// relative to the coordinate spaces.
    /// - Returns: The reality view for the volumetric window.
    private func createVolumetricWindowRealityView() -> some View {
        RealityView { content, attachments in
            createContentAndPositionAttachments(content, attachments)
        } attachments: {
            createAttachment("immersive", appModel.spaceTransform)
            createAttachment("scene", appModel.sceneTransform)
        }
    }
    
    /// Creates the reality view content and positions the attachments.
    ///
    /// The method does the following:
    /// - Adds a cube entity that moves between the volumetric window and the immersive space.
    /// - Adds a cube entity that fills the volume of the window to shows the extent of the window.
    /// - Positions the scene and immersive space transform text attachments.
    /// - Parameters:
    ///   - content: The `RealityViewContent` of the volumetric window that the cube entities are added to.
    ///   - attachments: The attachments associated with the reality view positioned relative to the cube.
    private func createContentAndPositionAttachments(
        _ content: RealityViewContent, _ attachments: RealityViewAttachments
    ) {
        // Create the cube that moves between the volumetric and immersive views.
        createCube()

        // Create the cube that's the same size as the volumetric window.
        let volumetricWindowCube = createVolumetricWindowCube()

        // Add the entities to the reality view content.
        content.add(appModel.volumeRootEntity)
        content.add(appModel.volumeCubeLastSceneTransformEntity)
        content.add(volumetricWindowCube)

        // Position the scene transform attachment below the volume cube.
        appModel.sceneAttachmentEntity = positionAttachment(
            "scene", [0, -0.15, 0], attachments)
        
        // Position the immersive space transform attachment above the volume cube.
        immersiveAttachmentEntity = positionAttachment(
            "immersive", [0, 0.15, 0], attachments)
        
        // Disable the immersive space attachment because the immersive space is hidden by default.
        immersiveAttachmentEntity?.isEnabled = appModel.immersiveSpaceIsShown
    }

    /// Create the cube that a person moves between the volumetric and immersive views.
    private func createCube() {

        appModel.volumeCube.components.set([
            ModelComponent(
                mesh: .generateBox(size: 0.1, cornerRadius: 0.01),
                materials: [appModel.volumetricMaterial]),
            InputTargetComponent(allowedInputTypes: .indirect),
            HoverEffectComponent(),
            CollisionComponent(shapes: [
                ShapeResource.generateBox(size: [0.1, 0.1, 0.1])
            ])
        ])
        
        // Make the volume cube a subentity of the volumetric window's root.
        appModel.volumeRootEntity.addChild(appModel.volumeCube)
    }
    
    /// Creates the cube entity, which is the size of the volumetric window. This helps
    ///  visualize the bounds of the volumetric window.
    /// - Returns: The cube entity that represents the size of the volumetric window.
    private func createVolumetricWindowCube() -> ModelEntity {
        var volumetricWindowCubematerial = SimpleMaterial(
            color: #colorLiteral(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.4),
            roughness: 0.5,
            isMetallic: false)

        volumetricWindowCubematerial.faceCulling = .front

        let volumetricWindowCube = ModelEntity(
            mesh: .generateBox(size: 1.0, cornerRadius: 0.1),
            materials: [volumetricWindowCubematerial])

        return volumetricWindowCube
    }
    
    /// Create the text attachment showing the given transform's translation values.
    /// - Parameters:
    ///   - id: The identifier for the attachment which is also shown in the text.
    ///   - transform: The transform whose translation is shown in the text.
    /// - Returns: The attachment containing the text.
    private func createAttachment(_ id: String, _ transform: Transform) -> Attachment<some View> {
        
        // Set the precision of the value of each axis to 2 decimal points.
        let xFormatted = String(format: "%.2f", transform.translation.x)
        let yFormatted = String(format: "%.2f", transform.translation.y)
        let zFormatted = String(format: "%.2f", transform.translation.z)
        
        return Attachment(id: id) {
            Text("\(id): \n x: \(xFormatted) y: \(yFormatted) z: \(zFormatted)")
                .font(.extraLargeTitle)
                .padding()
                .glassBackgroundEffect()
                .multilineTextAlignment(.center)
        }
    }
    
    /// Position the attachment relative to the volume cube.
    /// - Parameters:
    ///   - id: The identifier of the attachemnt containing the text.
    ///   - positionOffset: The position relative to the root of the attachment that is the volume cube.
    ///   - attachments: The reality view attachments associated with the volumetric view.
    /// - Returns: The entity associated with the attachment.
    private func positionAttachment(
        _ id: String, _ positionOffset: SIMD3<Float>,
        _ attachments: RealityViewAttachments
    ) -> Entity? {
        
        // Find the attachment using the identifier.
        guard let attachment = attachments.entity(for: id) else {
            return nil
        }
        
        // Make the attachment a subentity of the volume cube.
        appModel.volumeCube.addChild(attachment)
        
        // Set the attachment's position relative to the volume cube.
        attachment.position = positionOffset
        
        // Ensure that the attachment always orients towards the active camera.
        attachment.components.set(BillboardComponent())

        return attachment
    }
    
    /// Move the cube from a volumetric window to an immersive space using a double-tap gesture.
    private var doubleTapMove: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                moveCubeFromVolumetricWindowToImmersiveSpace()
                appModel.cubeInImmersiveSpace = true
            }
    }
    
    /// Moves the cube from the volumetric window to the immersive space.
    private func moveCubeFromVolumetricWindowToImmersiveSpace() {
        
        // Only move the cube if the immersive space is open.
        guard appModel.immersiveSpaceIsShown else { return }

        // Record the cube's transform before moving it to the immersive space.
        // The app uses this information to move the cube back to the volumetric window.
        appModel.volumeCubeLastSceneTransformEntity.transform = appModel.volumeCube.transform

        // Get the transformation matrix of the cube relative to the immersive space.
        let cubeToSpaceMatrix = appModel.volumeCube.transformMatrix(relativeTo: .immersiveSpace)

        // Add the cube as a child of the immersive space's root entity.
        appModel.immersiveSpaceRootEntity.addChild(appModel.volumeCube)
        
        // Set the transformation matrix of the cube relative to the immersive space.
        appModel.volumeCube.setTransformMatrix(cubeToSpaceMatrix ?? matrix_identity_float4x4,
                                               relativeTo: appModel.volumeCube.parent)

        // Change the material to the immersive space material.
        appModel.volumeCube.components[ModelComponent.self]?.materials = [
            appModel.immersiveSpaceMaterial
        ]

        // Disable the scene transform attachment as the volume cube is in the immersive space now.
        appModel.sceneAttachmentEntity?.isEnabled = false
        
        appModel.cubeInImmersiveSpace = true
    }
    
    /// Enables the immersive space transform attachment if the immersive space is open.
    private func enableImmsersiveAttachment() {
        immersiveAttachmentEntity?.isEnabled = appModel.immersiveSpaceIsShown
    }
    
    /// Handle the change in the transform of the volumetric window.
    /// - Parameter proxy: The proxy structure to access the transform when it changes.
    /// - Returns: The transform after conversion to immersive space.
    /// Note: The return value isn't used in the action.
    private func onGeometryChangeTransform(_ proxy: GeometryProxy) -> AffineTransform3D {
        return proxy.transform(in: .immersiveSpace) ?? .identity
    }
    
    /// Update the immersive space transform in the app model.
    /// - Parameter transform: The transform value of the volumetric window that has changed.
    /// Note: The argument is unused.
    private func updateImmersiveSpaceTransform(_ transform: AffineTransform3D) {
        appModel.updateTransform(relativeTo: .immersiveSpace)
    }
    
    /// The toolbar item group that contains the immersive space toggle button.
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            toolBarContentView
        }
    }

    /// The view for the toolbar that contains the immersive space toggle button.
    @ViewBuilder
    private var toolBarContentView: some View {
        VStack {
            Button {
                appModel.showImmersiveSpace.toggle()
            } label: {
                Text(
                    appModel.showImmersiveSpace
                        ? "Hide Immersive Space"
                        : "Show Immersive Space")
            }
            Button {
                if appModel.cubeInImmersiveSpace {
                    appModel.moveCubeFromImmersiveSpaceToVolumetricWindow()
                } else {
                    moveCubeFromVolumetricWindowToImmersiveSpace()
                }
            } label: {
                Text(
                    appModel.cubeInImmersiveSpace
                        ? "Move Cube To Volumetric Window"
                        : "Move Cube To Immersive Space")
            }.disabled(!appModel.showImmersiveSpace)
        }
    }
}

#Preview(windowStyle: .volumetric) {
    VolumetricView()
        .environment(AppModel())
}
