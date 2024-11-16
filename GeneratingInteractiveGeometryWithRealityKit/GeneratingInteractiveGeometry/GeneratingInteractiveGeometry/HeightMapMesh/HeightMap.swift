/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure that generates a low-level texture suitable for containing the height and normal information that defines a height map.
*/

import RealityKit
import Metal

@MainActor
struct HeightMap {
    /// Compute pipeline corresponding to the Metal compute shader function `deriveNormalsFromHeightMap`.
    ///
    /// See `HeightMapMeshComputeShader.metal`.
    private let deriveNormalsPipeline: MTLComputePipelineState = makeComputePipeline(named: "deriveNormalsFromHeightMap")!
    
    /// The generator that generates the height values of the height map.
    var heightMapGenerator: HeightMapGenerator = SineWaveHeightMapGenerator()

    /// The low-level texture that stores the height and normal information of the height map.
    var heightMapTexture: LowLevelTexture
    
    init(dimensions: SIMD2<UInt32>) throws {
        // Initialize the texture with an RGBA pixel format where the alpha channel stores height,
        // while the red, green, and blue channels store the surface normal direction.
        let textureDescriptor = LowLevelTexture.Descriptor(pixelFormat: .rgba32Float,
                                                           width: Int(dimensions.x),
                                                           height: Int(dimensions.y),
                                                           textureUsage: [.shaderRead, .shaderWrite])
        self.heightMapTexture = try LowLevelTexture(descriptor: textureDescriptor)
    }
    
    /// Generates the height values in the alpha channel of the height map using the current `heightMapGenerator`.
    func generateHeight(computeContext: ComputeUpdateContext, heightMapComputeParams: HeightMapComputeParams) {
        heightMapGenerator.generateHeightMap(computeContext: computeContext,
                                             heightMapTexture: heightMapTexture,
                                             heightMapComputeParams: heightMapComputeParams)
    }
    
    /// Updates the normal directions in the RGB channels of the height map using the current height values.
    func updateNormals(computeContext: ComputeUpdateContext, heightMapComputeParams: HeightMapComputeParams) {
        // Get the command buffer and compute encoder.
        let commandBuffer = computeContext.commandBuffer
        let computeEncoder = computeContext.computeEncoder
        // Get the threadgroups.
        let threadgroups = heightMapComputeParams.threadgroups
        let threadsPerThreadgroup = heightMapComputeParams.threadsPerThreadgroup
        
        // Set the cell size parameter.
        var cellSize = heightMapComputeParams.cellSize
        
        // Set the compute shader pipeline to `deriveNormalsFromHeightMap`.
        computeEncoder.setComputePipelineState(deriveNormalsPipeline)
        
        // Pass a readable version of the height map texture to the compute shader.
        computeEncoder.setTexture(heightMapTexture.read(), index: 0)
        // Pass a writable version of the height map texture to the compute shader.
        computeEncoder.setTexture(heightMapTexture.replace(using: commandBuffer), index: 1)
        
        // Pass the cell size to the compute shader.
        computeEncoder.setBytes(&cellSize, length: MemoryLayout<SIMD2<Float>>.size, index: 2)
        
        // Dispatch the compute shader.
        computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}
