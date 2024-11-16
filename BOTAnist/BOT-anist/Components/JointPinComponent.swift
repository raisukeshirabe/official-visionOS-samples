/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object that holds information needed to "pin" the static head and backpack to the animated skeleton.
*/

import Foundation
import RealityKit

public struct JointPinComponent: Component {
    let headEntity: Entity
    let headJointIndices: [Int]
    let backpackEntity: Entity
    let backpackJointIndices: [Int]
    let bodyEntity: Entity
    let headOffset: simd_float4x4
    let backpackOffset: simd_float4x4
    
    public init(headEntity: Entity,
                headJointIndices: [Int],
                headOffset: simd_float4x4,
                backpackEntity: Entity,
                backpackJointIndices: [Int],
                backpackOffset: simd_float4x4,
                bodyEntity: Entity) {
        self.headEntity = headEntity
        self.headJointIndices = headJointIndices
        self.backpackEntity = backpackEntity
        self.backpackJointIndices = backpackJointIndices
        self.bodyEntity = bodyEntity
        self.headOffset = headOffset
        self.backpackOffset = backpackOffset
    }
}
