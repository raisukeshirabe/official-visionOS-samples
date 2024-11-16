/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A system that keeps static meshes connected to the joint of a rigged entity.
*/
import Foundation
import RealityKit
import SwiftUI

public struct JointPinSystem: System {
    
    let skeletonQuery = EntityQuery(where: .has(JointPinComponent.self))

    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        
        for skeleton in context.entities(matching: skeletonQuery, updatingSystemWhen: .rendering) {
            guard let skeleton = skeleton as? ModelEntity,
                  let component = skeleton.jointPinComponent else { fatalError("Skeleton doesn't have required joint pin component.") }

            let transforms = skeleton.jointTransforms
            
            pinEntity(indices: component.headJointIndices,
                      skeleton: skeleton,
                      transforms: transforms,
                      offset: component.headOffset,
                      staticEntity: component.headEntity,
                      shouldRotate: component.bodyEntity.name == "body1")
            
            pinEntity(indices: component.backpackJointIndices,
                      skeleton: skeleton,
                      transforms: transforms,
                      offset: component.backpackOffset,
                      staticEntity: component.backpackEntity)
        }
    }
    
    @MainActor
    @inline(__always)
    fileprivate func pinEntity(indices: [Int],
                               skeleton: ModelEntity,
                               transforms: [Transform],
                               offset: simd_float4x4,
                               staticEntity: Entity,
                               shouldRotate: Bool = false) {
        
        var transform = indices.reduce(matrix_identity_float4x4) { partialResult, index in
            transforms[index].matrix * partialResult
        }
        
        if shouldRotate {
            let unrotate = simd_quatf(angle: -(Float.pi / 2.0), axis: [0, 0, 1.0])
            let unrotateMatrix = Transform(matrix: matrix_float4x4(unrotate)).matrix
            transform *= unrotateMatrix
        }
        
        staticEntity.setTransformMatrix(transform * offset, relativeTo: skeleton)
    }
}
 
