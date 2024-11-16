/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class responsible for dispatching the compute shader function that generates the sine wave height map.
*/

import RealityKit
import Metal

@MainActor
class SineWaveHeightMapGenerator: HeightMapGenerator {
    /// Compute pipeline corresponding to the Metal compute shader function `generateSineWaveHeightMap`.
    ///
    /// See `SineWaveComputeShader.metal`.
    private let sineWaveHeightPipeline: MTLComputePipelineState = makeComputePipeline(named: "generateSineWaveHeightMap")!
    
    /// The number of seconds elapsed since the person reset this generator.
    private var time: Float = 0
    
    /// The amplitude of the sine wave this generator generates.
    private var amplitude: Float = 0.05

    /// Resets the time to zero.
    func reset() {
        time = 0
    }
    
    /// Dispatches a Metal compute shader to generate a height map in the shape of a sine wave.
    func generateHeightMap(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams) {
        // Get deltaTime.
        let deltaTime = Float(computeContext.deltaTime)
        // Get the command buffer and compute encoder.
        let commandBuffer = computeContext.commandBuffer
        let computeEncoder = computeContext.computeEncoder
        // Get the threadgroups.
        let threadgroups = heightMapComputeParams.threadgroups
        let threadsPerThreadgroup = heightMapComputeParams.threadsPerThreadgroup
        
        // Increment time.
        time += deltaTime
        
        // Set the compute shader pipeline to `generateSineWaveHeightMap`.
        computeEncoder.setComputePipelineState(sineWaveHeightPipeline)
        
        // Pass a readable version of the height map texture to the compute shader.
        computeEncoder.setTexture(heightMapTexture.read(), index: 0)
        // Pass a writable version of the height map texture to the compute shader.
        computeEncoder.setTexture(heightMapTexture.replace(using: commandBuffer), index: 1)
        
        // Pass the time to the compute shader.
        computeEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 2)
        // Pass the amplitude to the compute shader.
        computeEncoder.setBytes(&amplitude, length: MemoryLayout<Float>.size, index: 3)
        
        // Dispatch the compute shader.
        computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}
