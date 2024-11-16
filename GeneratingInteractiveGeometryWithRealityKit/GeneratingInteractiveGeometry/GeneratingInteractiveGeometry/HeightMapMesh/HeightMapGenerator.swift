/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A protocol that enables the generation of custom height maps.
*/

import RealityKit
import Metal

@MainActor
protocol HeightMapGenerator {
    /// Resets the height map.
    func reset()
    
    /// Generates the height map.
    func generateHeightMap(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams)
}
