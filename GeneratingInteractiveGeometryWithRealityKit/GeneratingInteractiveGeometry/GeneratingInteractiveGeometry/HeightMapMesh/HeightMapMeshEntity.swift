/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An entity with a mesh that the height map mesh generates.
*/

import Foundation
import RealityKit
import MetalKit

class HeightMapMeshEntity: Entity, HasModel {
    /// The height map mesh this entity renders.
    var heightMapMesh: HeightMapMesh?
    
    /// Sets up the entity by creating a `HeightMapMesh` and adding the necessary components.
    private func setup(size: SIMD2<Float>, dimensions: SIMD2<UInt32>, maxVertexDepth: Float) {
        // Try to create a `HeightMapMesh` and get its low-level mesh.
        guard let heightMapMesh = try? HeightMapMesh(size: size, dimensions: dimensions, maxVertexDepth: maxVertexDepth),
              let planeMesh = try? MeshResource(from: heightMapMesh.planeMesh.mesh) else {
            assertionFailure("Failed to create height map mesh and get its low-level mesh.")
            return
        }
        self.heightMapMesh = heightMapMesh
        
        // Add a compute system component with the height map mesh as its compute system.
        self.components.set(ComputeSystemComponent(computeSystem: heightMapMesh))

        // Add a model component with the plane mesh.
        self.components.set(ModelComponent(mesh: planeMesh, materials: [SimpleMaterial()]))

        // Make this entity capable of receiving gestures by giving it an input target component and a collider.
        self.components.set(InputTargetComponent())
        let collisionBoxDepth: Float = 0.025
        let collisionBox = ShapeResource.generateBox(width: size.x, height: size.y, depth: collisionBoxDepth)
            .offsetBy(translation: [0, 0, -collisionBoxDepth / 2])
        self.components.set(CollisionComponent(shapes: [collisionBox]))
    }
    
    /// The custom initializer.
    ///
    /// Sets up the `heightMapMesh` with given size, dimensions, and maximum vertex depth.
    init(size: SIMD2<Float>, dimensions: SIMD2<UInt32>, maxVertexDepth: Float) {
        super.init()
        setup(size: size, dimensions: dimensions, maxVertexDepth: maxVertexDepth)
    }
    
    /// The default initializer.
    required init() {
        super.init()
        setup(size: [1, 1], dimensions: [512, 512], maxVertexDepth: 1)
    }
}
