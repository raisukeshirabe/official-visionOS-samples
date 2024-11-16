/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that represents the stroke mesh that the drag gesture creates.
*/

import SwiftUI
import RealityKit

/// A structure to represent the stroke.
struct Stroke {
    /// The stroke that represents the stroke.
    var entity = Entity()

    /// The collection of points in 3D space that represent the stroke.
    var points: [SIMD3<Float>] = []

    /// The maximum radius of the stroke.
    let maxRadius: Float = 1E-2

    /// The number of points in each ring of the mesh.
    let pointsPerRing = 8

    /// Update the mesh with the points of the stroke if it already exists,
    /// or create a new one with the given mesh data.
    func updateMesh() {
        /// The starting point where the stroke mesh begins.
        guard let center = points.first else { return }

        /// The position, normals, and triangle indices that the points generate.
        let (positions, normals, triangles) = generateMeshData()

        /// The `MeshResource.Contents` instance.
        var contents = MeshResource.Contents()

        // Create and assign an instance to `contents`.
        contents.instances = [MeshResource.Instance(id: "main", model: "model")]

        // Create the part for the model, and set the vertex positions, triangle indices, and normals.
        var part = MeshResource.Part(id: "part", materialIndex: 0)
        part.positions = MeshBuffer(positions)
        part.triangleIndices = MeshBuffer(triangles)
        part.normals = MeshBuffer(normals)

        // Create and assign a model that consists of the `part`.
        contents.models = [MeshResource.Model(id: "model", parts: [part])]

        // Replace the mesh with `contents` if there is a mesh component on the entity.
        if let mesh = entity.model?.mesh {
            do {
                try mesh.replace(with: contents)
            } catch {
                print("Error replacing mesh: \(error.localizedDescription)")
            }
        } else {
            /// The new mesh that generates with `content`.
            guard let mesh = try? MeshResource.generate(from: contents) else {
                print("Error generating mesh")
                return
            }

            // Set the model component to the new mesh, and assign a simple material.
            entity.components.set(ModelComponent(
                mesh: mesh,
                materials: [SimpleMaterial(color: .white, roughness: 1.0, isMetallic: false)]
            ))

            // Set the entity's transform and position.
            entity.setTransformMatrix(.identity, relativeTo: nil)
            entity.setPosition(center, relativeTo: nil)
        }
    }

    // MARK: Helper functions

    /// Generate the mesh data with the current points.
    private func generateMeshData() -> ([SIMD3<Float>], [SIMD3<Float>], [UInt32]) {
        /// The array to store vertex positions.
        var positions: [SIMD3<Float>] = []

        /// The array to store normal vectors.
        var normals: [SIMD3<Float>] = []

        /// The array to store triangle indices.
        var triangles: [UInt32] = []

        // Iterates through the points to create a path for the mesh.
        for pointIdx in 0..<points.count {
            /// The radius and direction for the current point.
            let (radius, direction) = calculateRadiusAndDirection(at: pointIdx)

            /// The x and y axes for the current point.
            let (xAxis, yAxis) = calculateAxes(direction: direction)

            // Generate points around the current stroke point.
            for point in 0..<pointsPerRing {
                /// The position and normal for the current point in the ring.
                let (position, normal) = calculatePositionAndNormal(pointI: pointIdx, point: point, radius: radius, xAxis: xAxis, yAxis: yAxis)

                // Attach the position to the positions collection.
                positions.append(position)

                // Attach the normal to the normals collection.
                normals.append(normal)

                // Generate a mesh between each point.
                if pointIdx + 1 < points.count {
                    appendTriangles(pointIdx: pointIdx, point: point, triangles: &triangles)
                }
            }
        }

        return (positions, normals, triangles)
    }

    /// Calculate the radius and direction from a given point index.
    private func calculateRadiusAndDirection(at index: Int) -> (Float, SIMD3<Float>) {
        // End the stroke if there are no points.
        if index == 0 || (index + 1 == points.count) {
            // For the first and last points, use zero radius and default direction.
            return (0, SIMD3<Float>(1, 0, 0))
        } else {
            /// The difference between the current point and the previous point.
            let diff = points[index] - points[index - 1]

            /// The radius calculated from the difference.
            let radius = maxRadius * powf(clamp(Float(maxRadius / length(diff)), min: Float(0), max: Float(1)), 0.3)

            return (radius, normalize(diff))
        }
    }

    /// Calculate the x and y axes with the given direction.
    private func calculateAxes(direction: SIMD3<Float>) -> (SIMD3<Float>, SIMD3<Float>) {
        /// The cross product of the direction and the y-axis that normalizes.
        let xAxis = normalize(cross(direction, SIMD3<Float>(0, 1, 0)))

        /// The cross product of the direction and `xAxis` value that normalizes.
        let yAxis = normalize(cross(direction, xAxis))

        return (xAxis, yAxis)
    }

    /// Calculate the position and normal for a point in the ring around a stroke point.
    private func calculatePositionAndNormal(
        pointI: Int, point: Int, radius: Float, xAxis: SIMD3<Float>, yAxis: SIMD3<Float>) -> (SIMD3<Float>, SIMD3<Float>) {
            /// The angle is the product of two times pi, then divide the total points per ring.
            let angle = 2 * .pi * Float(point) / Float(pointsPerRing)

            /// The current normal value from the angle.
            let normal = cos(angle) * xAxis + sin(angle) * yAxis

            /// The location of the current point with its distance from the center point.
            let position = (points[pointI] - points[0]) + radius * normal

            return (position, normal)
        }

    /// Add triangle indices for the current point in the mesh.
    private func appendTriangles(pointIdx: Int, point: Int, triangles: inout [UInt32]) {
        /// The collection of points in an array to define the shape for the mesh.
        let quadIndices: [UInt32] = [
            UInt32(pointsPerRing * (pointIdx + 0) + (point + 0) % pointsPerRing),
            UInt32(pointsPerRing * (pointIdx + 1) + (point + 0) % pointsPerRing),
            UInt32(pointsPerRing * (pointIdx + 0) + (point + 1) % pointsPerRing),
            UInt32(pointsPerRing * (pointIdx + 1) + (point + 1) % pointsPerRing)
        ]

        // Add the contents of the fourth, first, and third entry from the
        // `quadIndices` array to the `triangles` collection.
        triangles.append(contentsOf: [quadIndices[3], quadIndices[0], quadIndices[2]])

        // Add the contents of the fourth, second, and first entry from the
        // `quadIndices` array to the `trinagles` collection.
        triangles.append(contentsOf: [quadIndices[3], quadIndices[1], quadIndices[0]])
    }
}
