/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's window view.
*/

import SwiftUI
import RealityKit

struct UIPortalView: View {
    /// The environment value to get the `OpenImmersiveSpaceAction` instance.
    @Environment(\.openImmersiveSpace) var openImmersiveSpace

    /// The environment value to get the `dismissImmersiveSpace` instance.
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    /// A Boolean value that indicates whether the app shows the immersive space.
    @State var immersive: Bool = false

    /// The root entity for other entities within the scene.
    private let root = Entity()

    /// A plane entity representing a portal.
    private let portalPlane = ModelEntity(
        mesh: .generatePlane(width: 1.0, height: 1.0),
        materials: [PortalMaterial()]
    )

    var body: some View {
        if !immersive {
            portalView
        } else {
            /// A button that dismisses the immersive space when someone taps it.
            Button("Exit") {
                immersive = false
                Task {
                    await dismissImmersiveSpace()
                }
            }
        }
    }

    /// A view that contains a portal and a button that opens the immersive space.
    var portalView: some View {
        ZStack {
            GeometryReader3D { geometry in
                RealityView { content in
                    await createPortal()
                    content.add(root)
                } update: { content in
                    // Resize the scene based on the size of the reality view content.
                    let size = content.convert(geometry.size, from: .local, to: .scene)
                    updatePortalSize(width: size.x, height: size.y)
                }.frame(depth: 0.4)
            }.frame(depth: 0.4)

            VStack {
                Text("Tap the button to enter the environment.")

                /// A button that opens the immersive space when someone taps it.
                Button("Enter") {
                    immersive = true
                    Task {
                        await openImmersiveSpace(id: "UIPortal")
                    }
                }
            }
        }
    }

    /// Sets up the portal and adds it to the `root.`
    @MainActor func createPortal() async {
        // Create the entity that stores the content within the portal.
        let world = Entity()

        // Shrink the portal world and update the position
        // to make it fit into the portal view.
        world.scale *= 0.5
        world.position.y -= 0.5
        world.position.z -= 0.5

        // Allow the entity to be visible only through a portal.
        world.components.set(WorldComponent())
        
        do {
            // Create the box environment and add it to the root.
            try await createEnvironment(on: world)
            root.addChild(world)

            // Set up the portal to show the content in the `world`.
            portalPlane.components.set(PortalComponent(target: world))
            root.addChild(portalPlane)
        } catch {
            fatalError("Failed to create environment: \(error)")
        }
    }

    /// Configures the portal mesh's width and height.
    func updatePortalSize(width: Float, height: Float) {
        portalPlane.model?.mesh = .generatePlane(width: width, height: height, cornerRadius: 0.03)
    }
}
