/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A visual representation of the positive directions along the x, y, and z-axis.
*/

import RealityKit

/// The structure that creates a visible representation of the x, y, and z axes.
struct AxisVisualizer {
    /// Builds the axis visualizer entity.
    static func make() -> Entity {
        /// The entity that contains four different meshes.
        let entity = Entity()

        /// The width, length, and radius values that each mesh uses.
        let width: Float = 0.0025
        let length: Float = 0.1
        let radius: Float = 0.005

        /// The box for the x-axis.
        let xAxisMesh = MeshResource.generateBox(size: [length, width, width])

        /// The unlit red material.
        let xAxisMaterial = UnlitMaterial(color: .systemRed)

        /// The entity with the box and material that represents the x-axis.
        let xAxisEntity = ModelEntity(mesh: xAxisMesh, materials: [xAxisMaterial])

        // Set the postion of the x-axis entity in 3D space.
        xAxisEntity.position = [0.5 * length, 0, 0]

        // Add the x-axis to the parent entity.
        entity.addChild(xAxisEntity)

        /// The box for the y-axis.
        let yAxisMesh = MeshResource.generateBox(size: [width, length, width])

        /// The unlit green material.
        let yAxisMaterial = UnlitMaterial(color: .systemGreen)

        /// The entity with the box and material that represents the y-axis.
        let yAxisEntity = ModelEntity(mesh: yAxisMesh, materials: [yAxisMaterial])

        // Set the position of the y-axis entity in 3D space.
        yAxisEntity.position = [0, 0.5 * length, 0]

        // Add the y-axis to the parent entity.
        entity.addChild(yAxisEntity)

        /// The box for the z-axis.
        let zAxisMesh = MeshResource.generateBox(size: [width, width, length])

        /// The unlit blue material.
        let zAxisMaterial = UnlitMaterial(color: .systemBlue)

        /// The entity with the box and material that represents the z-axis.
        let zAxisEntity = ModelEntity(mesh: zAxisMesh, materials: [zAxisMaterial])

        // Set the position of the z-axis entity in 3D space.
        zAxisEntity.position = [0, 0, 0.5 * length]

        // Add the z-axis to the main entity.
        entity.addChild(zAxisEntity)

        /// The sphere for the origin point.
        let originMesh = MeshResource.generateSphere(radius: radius)

        /// The unlit white material.
        let originMaterial = UnlitMaterial(color: .white)

        /// The entity with the sphere and white material that represents the origin point.
        let originEntity = ModelEntity(mesh: originMesh, materials: [originMaterial])

        // Add the origin point to the parent entity.
        entity.addChild(originEntity)

        return entity
    }
}
