/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A RealityView window that will spawn a volumetric window that contains a 3D Object.
*/

import SwiftUI
import RealityKit

/// A view that loads in a 3D model and sets the dimensions of the volumetric window to the same size as the model.
struct VolumetricWindow: View {
    /// The default length of each side of the cubic volumetric window, in meters.
    static let defaultSize: CGFloat = 0.5

    /// The name of the model to load in.
    let modelName: String = "cup_saucer_set"

    var body: some View {
        // Get the height, width, and depth information
        // of the view with a geometry reader.
        GeometryReader3D { geometry in
            RealityView { content in
                // Attempt to load the entity that uses the file name as a source.
                guard let model = try? await ModelEntity(named: modelName) else {
                    return
                }

                // Add the model to the `RealityView`.
                content.add(model)
            }
            update: { content in
                // Get the loaded entity to resize.
                guard let model = content.entities.first(where: { $0.name == modelName }) else {
                    return
                }

                /// The volume's dimensions in local coordinates.
                let viewBounds = content.convert(
                    geometry.frame(in: .local),
                    from: .local,
                    to: .scene
                )

                // Set the model's position to the bottom of the visual bounding box.
                model.position.y -= model.visualBounds(relativeTo: nil).min.y

                // Adjust the model's position on the y-axis to align with the view bounds.
                model.position.y += viewBounds.min.y

                /// The base size of the model when the scale is 1.
                let baseExtents = model.visualBounds(relativeTo: nil).extents / model.scale

                /// The scale required for the model to fit the bounds of the volumetric window.
                let scale = Float(viewBounds.extents.x) / baseExtents.x

                // Apply the scale to the model to fill the full size of the window.
                model.scale = SIMD3<Float>(repeating: scale)
            }
        }
    }
}

#Preview (windowStyle: .volumetric) {
    VolumetricWindow()
}
