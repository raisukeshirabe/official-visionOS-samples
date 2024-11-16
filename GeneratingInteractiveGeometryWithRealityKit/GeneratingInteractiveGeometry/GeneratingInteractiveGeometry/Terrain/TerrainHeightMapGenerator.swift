/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class responsible for dispatching the compute shader functions that reset and add terrain to the height map.
*/

import RealityKit
import Metal
import MetalKit

@MainActor
class TerrainHeightMapGenerator: HeightMapGenerator {
    /// Compute pipeline corresponding to the Metal compute shader function `resetTerrainHeightMap`.
    ///
    /// See `TerrainComputeShader.metal`.
    private let resetPipeline: MTLComputePipelineState = makeComputePipeline(named: "resetTerrainHeightMap")!
    /// Compute pipeline corresponding to the Metal compute shader function `addHeightToTerrainHeightMap`.
    ///
    /// See `TerrainComputeShader.metal`.
    private let addHeightPipeline: MTLComputePipelineState = makeComputePipeline(named: "addHeightToTerrainHeightMap")!

    /// The default terrain texture height map.
    private var terrainTexture: MTLTexture? = nil
    /// The brush texture that adds height to the height map.
    private var brushTexture: MTLTexture? = nil
    /// Whether or not to reset the terrain back to the default terrain texture height map.
    private var resetTerrain: Bool = false
    
    /// Initializes the generator by loading the terrain height map and terrain brush textures.
    init() {
        if let terrainTextureUrl = Bundle.main.url(forResource: "TerrainHeightMap", withExtension: "png") {
            terrainTexture = try? MTKTextureLoader(device: metalDevice.unsafelyUnwrapped).newTexture(URL: terrainTextureUrl, options: nil)
        }
        
        if let brushTextureUrl = Bundle.main.url(forResource: "TerrainBrush", withExtension: "png") {
            brushTexture = try? MTKTextureLoader(device: metalDevice.unsafelyUnwrapped).newTexture(URL: brushTextureUrl, options: nil)
        }
    }
    
    /// Toggles the `resetTerrain` flag to true.
    func reset() {
        resetTerrain = true
    }
    
    /// Dispatches a Metal compute shader to generate a height map in the shape of terrain.
    func generateHeightMap(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams) {
        // Set the terrain compute parameters.
        var terrainParams = TerrainParams(brushPosition: simd_make_float2(heightMapComputeParams.interactionPosition),
                                          brushSize: 25 * heightMapComputeParams.cellSize.x,
                                          brushInfluence: 0.1 * Float(computeContext.deltaTime),
                                          dimensions: heightMapComputeParams.dimensions,
                                          size: heightMapComputeParams.size)
        
        // Reset the height map to the initial terrain height map when the `resetTerrain` flag is true.
        if resetTerrain {
            computeContext.computeEncoder.setComputePipelineState(resetPipeline)
            computeContext.computeEncoder.setBytes(&terrainParams, length: MemoryLayout<TerrainParams>.size, index: 0)
            computeContext.computeEncoder.setTexture(terrainTexture, index: 1)
            computeContext.computeEncoder.setTexture(heightMapTexture.replace(using: computeContext.commandBuffer), index: 2)
            computeContext.computeEncoder.dispatchThreadgroups(heightMapComputeParams.threadgroups,
                                                               threadsPerThreadgroup: heightMapComputeParams.threadsPerThreadgroup)
            resetTerrain = false
        }
        
        // Add height with the height brush texture when an interaction is happening.
        if heightMapComputeParams.isInteractionHappening {
            computeContext.computeEncoder.setComputePipelineState(addHeightPipeline)
            computeContext.computeEncoder.setBytes(&terrainParams, length: MemoryLayout<TerrainParams>.size, index: 0)
            computeContext.computeEncoder.setTexture(brushTexture, index: 1)
            computeContext.computeEncoder.setTexture(heightMapTexture.read(), index: 2)
            computeContext.computeEncoder.setTexture(heightMapTexture.replace(using: computeContext.commandBuffer), index: 3)
            computeContext.computeEncoder.dispatchThreadgroups(heightMapComputeParams.threadgroups,
                                                               threadsPerThreadgroup: heightMapComputeParams.threadsPerThreadgroup)
        }
    }
}
