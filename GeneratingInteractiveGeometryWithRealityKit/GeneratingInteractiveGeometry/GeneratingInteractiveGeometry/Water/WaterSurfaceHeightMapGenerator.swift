/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class responsible for dispatching the compute shader functions that simulate the water surface.
*/

import RealityKit
import Metal

@MainActor
class WaterSurfaceHeightMapGenerator: HeightMapGenerator {
    /// Compute pipeline corresponding to the Metal compute shader function `resetWaterSurface`.
    ///
    /// See `WaterSurfaceComputeShader.metal`.
    private let resetWaterSurfacePipeline: MTLComputePipelineState = makeComputePipeline(named: "resetWaterSurface")!
    /// Compute pipeline corresponding to the Metal compute shader function `disturbWaterSurface`.
    ///
    /// See `WaterSurfaceComputeShader.metal`.
    private let disturbWaterSurfacePipeline: MTLComputePipelineState = makeComputePipeline(named: "disturbWaterSurface")!
    /// Compute pipeline corresponding to the Metal compute shader function `updateWaterVelocity`.
    ///
    /// See `WaterSurfaceComputeShader.metal`.
    private let udpateWaterVelocityPipeline: MTLComputePipelineState = makeComputePipeline(named: "updateWaterVelocity")!
    /// Compute pipeline corresponding to the Metal compute shader function `updateWaterHeight`.
    ///
    /// See `WaterSurfaceComputeShader.metal`.
    private let updateWaterHeightPipeline: MTLComputePipelineState = makeComputePipeline(named: "updateWaterHeight")!
    
    /// The water velocity map.
    ///
    /// Each pixel stores the vertical velocity of the water column that pixel corresponds to.
    private var waterVelocityTexture: LowLevelTexture?
    /// Whether or not to reset the water height map.
    private var resetWater: Bool = false
    
    /// Toggles the `resetWater` flag to true.
    func reset() {
        resetWater = true
    }
    
    // Resets the water surface by dispatching a compute shader that clears the height and velocity textures.
    func resetWaterSurface(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams,
                           waterParams: inout WaterParams) {
        computeContext.computeEncoder.setComputePipelineState(resetWaterSurfacePipeline)
        computeContext.computeEncoder.setBytes(&waterParams, length: MemoryLayout<WaterParams>.size, index: 0)
        computeContext.computeEncoder.setTexture(heightMapTexture.replace(using: computeContext.commandBuffer), index: 1)
        computeContext.computeEncoder.setTexture(waterVelocityTexture?.replace(using: computeContext.commandBuffer), index: 2)
        computeContext.computeEncoder.dispatchThreadgroups(heightMapComputeParams.threadgroups,
                                                           threadsPerThreadgroup: heightMapComputeParams.threadsPerThreadgroup)
    }
    
    // Disturbs the water surface by dispatching a compute shader that increases/decreases the height
    // of the water around the disturbance position.
    func disturbWaterSurface(computeContext: ComputeUpdateContext,
                             heightMapTexture: LowLevelTexture,
                             heightMapComputeParams: HeightMapComputeParams,
                             waterParams: inout WaterParams) {
        // Dispatch the disturbance compute function.
        computeContext.computeEncoder.setComputePipelineState(disturbWaterSurfacePipeline)
        computeContext.computeEncoder.setBytes(&waterParams, length: MemoryLayout<WaterParams>.size, index: 0)
        computeContext.computeEncoder.setTexture(heightMapTexture.read(), index: 1)
        computeContext.computeEncoder.setTexture(heightMapTexture.replace(using: computeContext.commandBuffer), index: 2)
        computeContext.computeEncoder.dispatchThreadgroups(heightMapComputeParams.threadgroups,
                                                           threadsPerThreadgroup: heightMapComputeParams.threadsPerThreadgroup)
    }
    
    // Runs the water simulation by dispatching compute shaders to update the water velocity and height.
    func runWaterSimulation(computeContext: ComputeUpdateContext,
                            heightMapTexture: LowLevelTexture,
                            heightMapComputeParams: HeightMapComputeParams,
                            waterParams: inout WaterParams) {
        // Improve simulation consistency by iterating multiple times in a single frame.
        let iterationCount = 5
        waterParams.deltaTime /= Float(iterationCount)
        for _ in 0..<iterationCount {
            // Update the water velocity.
            computeContext.computeEncoder.setComputePipelineState(udpateWaterVelocityPipeline)
            computeContext.computeEncoder.setBytes(&waterParams, length: MemoryLayout<WaterParams>.size, index: 0)
            computeContext.computeEncoder.setTexture(heightMapTexture.read(), index: 1)
            computeContext.computeEncoder.setTexture(waterVelocityTexture?.read(), index: 2)
            computeContext.computeEncoder.setTexture(waterVelocityTexture?.replace(using: computeContext.commandBuffer), index: 3)
            computeContext.computeEncoder.dispatchThreadgroups(heightMapComputeParams.threadgroups,
                                                               threadsPerThreadgroup: heightMapComputeParams.threadsPerThreadgroup)

            // Update the water height.
            computeContext.computeEncoder.setComputePipelineState(updateWaterHeightPipeline)
            computeContext.computeEncoder.setBytes(&waterParams, length: MemoryLayout<WaterParams>.size, index: 0)
            computeContext.computeEncoder.setTexture(waterVelocityTexture?.read(), index: 1)
            computeContext.computeEncoder.setTexture(heightMapTexture.read(), index: 2)
            computeContext.computeEncoder.setTexture(heightMapTexture.replace(using: computeContext.commandBuffer), index: 3)
            computeContext.computeEncoder.dispatchThreadgroups(heightMapComputeParams.threadgroups,
                                                               threadsPerThreadgroup: heightMapComputeParams.threadsPerThreadgroup)
        }
    }
    
    func generateHeightMap(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams) {
        // Lazily initialize the water velocity texture.
        if waterVelocityTexture == nil {
            let textureDescriptor = LowLevelTexture.Descriptor(pixelFormat: .r32Float,
                                                               width: Int(heightMapComputeParams.dimensions.x),
                                                               height: Int(heightMapComputeParams.dimensions.y),
                                                               textureUsage: [.shaderRead, .shaderWrite])
            waterVelocityTexture = try? LowLevelTexture(descriptor: textureDescriptor)
        }
        
        // Set the water simulation parameters.
        var waterParams = WaterParams(deltaTime: Float(computeContext.deltaTime),
                                      waterSpeed: 0.05,
                                      disturbancePosition: [Float.infinity, Float.infinity],
                                      disturbanceRadius: 0,
                                      disturbanceAmount: 0,
                                      dimensions: heightMapComputeParams.dimensions,
                                      size: heightMapComputeParams.size,
                                      cellSize: heightMapComputeParams.cellSize)
        // Clamp delta time to ensure the simulation remains stable in cases with unexpectedly low frame rates.
        waterParams.deltaTime = Float.minimum(waterParams.deltaTime, (waterParams.cellSize.x / waterParams.waterSpeed))
        
        // Reset the water height and velocity to zero when the `resetWater` flag is true.
        if resetWater {
            resetWaterSurface(computeContext: computeContext,
                              heightMapTexture: heightMapTexture,
                              heightMapComputeParams: heightMapComputeParams,
                              waterParams: &waterParams)
            resetWater = false
        }
        
        // Simulate raindrops by randomly disturbing the water surface upward (essentially adding small water drops).
        if Float.random(in: 0...1) > 0.95 {
            waterParams.disturbancePosition = [Float.random(in: (-waterParams.size.x / 2)...(waterParams.size.x / 2)),
                                               Float.random(in: (-waterParams.size.y / 2)...(waterParams.size.y / 2))]
            waterParams.disturbanceRadius = 4 * waterParams.cellSize.x
            waterParams.disturbanceAmount = -8 * waterParams.cellSize.x
            disturbWaterSurface(computeContext: computeContext,
                                heightMapTexture: heightMapTexture,
                                heightMapComputeParams: heightMapComputeParams,
                                waterParams: &waterParams)
        }
        
        // Disturb the water surface downward at the position the person is interacting with it,
        // if an interaction is happening.
        if heightMapComputeParams.isInteractionHappening {
            waterParams.disturbancePosition = simd_make_float2(heightMapComputeParams.interactionPosition)
            waterParams.disturbanceRadius = 7 * waterParams.cellSize.x
            waterParams.disturbanceAmount = 250 * waterParams.cellSize.x * waterParams.deltaTime
            disturbWaterSurface(computeContext: computeContext,
                                heightMapTexture: heightMapTexture,
                                heightMapComputeParams: heightMapComputeParams,
                                waterParams: &waterParams)
        }
        
        // Run the water simulation.
        runWaterSimulation(computeContext: computeContext, heightMapTexture: heightMapTexture,
                           heightMapComputeParams: heightMapComputeParams, waterParams: &waterParams)
    }
}
