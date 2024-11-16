/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that modifies the vertex positions and normals of a plane mesh with a height map.
*/

import RealityKit
import Metal

/// A structure containing the parameters `HeightMap` needs to dispatch compute commands.
struct HeightMapComputeParams {
    /// The number of threadgroups to dispatch to when performing compute operations on the height map.
    let threadgroups: MTLSize
    /// The number of threads per threadgroup.
    let threadsPerThreadgroup: MTLSize
    /// The dimensions of the plane mesh.
    let dimensions: SIMD2<UInt32>
    /// The size of the plane mesh.
    let size: SIMD2<Float>
    /// The cell size of the plane mesh.
    let cellSize: SIMD2<Float>
    /// Whether or not an interaction is happening.
    let isInteractionHappening: Bool
    /// The current interaction position in local space.
    let interactionPosition: SIMD3<Float>
}

@MainActor
class HeightMapMesh: ComputeSystem {
    /// Whether or not an interaction is happening.
    var isInteractionHappening: Bool = false
    /// The current interaction position in local space.
    var interactionPosition: SIMD3<Float> = [0, 0, 0]
    
    /// Compute pipeline corresponding to the Metal compute shader function `setVertexData`.
    ///
    /// See `HeightMapMeshComputeShader.metal`.
    private let setVerticesPipeline: MTLComputePipelineState = makeComputePipeline(named: "setVertexData")!
    
    /// The dimensions of the plane mesh and the height map.
    let dimensions: SIMD2<UInt32>
    /// The size of the plane mesh.
    let size: SIMD2<Float>
    /// The cell size of the plane mesh.
    let cellSize: SIMD2<Float>
    
    /// The plane mesh that the height map modifies.
    var planeMesh: PlaneMesh
    /// The height map that modifies the plane mesh.
    var heightMap: HeightMap
    
    /// The GPU-friendly parameters describing the plane mesh.
    private var meshParams: MeshParams
    /// The number of threadgroups to dispatch when performing compute operations on the plane mesh or height map.
    private let threadgroups: MTLSize
    /// The number of threads per threadgroup.
    private let threadsPerThreadgroup: MTLSize
    
    init(size: SIMD2<Float>, dimensions: SIMD2<UInt32>, maxVertexDepth: Float) throws {
        assert(dimensions.x >= 2 && dimensions.y >= 2, "Height map mesh must have at least 2 vertices/pixels in each dimension.")
        self.dimensions = dimensions
        self.size = size
        self.cellSize = SIMD2<Float>(size.x / Float(dimensions.x - 1),
                                     size.y / Float(dimensions.y - 1))
        
        // Create the plane mesh and height map.
        self.planeMesh = try PlaneMesh(size: size, dimensions: dimensions, maxVertexDepth: maxVertexDepth)
        self.heightMap = try HeightMap(dimensions: dimensions)
        
        // Initialize the mesh parameters structure.
        self.meshParams = MeshParams(dimensions: dimensions, size: size, maxVertexDepth: maxVertexDepth)

        // Calculate the number of threadgroups to dispatch.
        let threadWidth = setVerticesPipeline.threadExecutionWidth
        let threadHeight = setVerticesPipeline.maxTotalThreadsPerThreadgroup / threadWidth
        self.threadsPerThreadgroup = MTLSize(width: threadWidth, height: threadHeight, depth: 1)
        self.threadgroups = MTLSize(width: (Int(dimensions.x) + threadWidth - 1) / threadWidth,
                                    height: (Int(dimensions.y) + threadHeight - 1) / threadHeight,
                                    depth: 1)
    }
    
    /// Dispatches a compute shader that sets the position and normal of each vertex in the mesh using the height map.
    private func updateVertices(computeContext: ComputeUpdateContext) {
        // Set the compute shader pipeline to `setVertexData`.
        computeContext.computeEncoder.setComputePipelineState(setVerticesPipeline)
        
        // Pass the mesh parameters to the compute shader.
        computeContext.computeEncoder.setBytes(&meshParams, length: MemoryLayout<MeshParams>.size, index: 0)
        // Pass the vertex buffer to the compute shader.
        let vertexBuffer = planeMesh.mesh.replace(bufferIndex: 0, using: computeContext.commandBuffer)
        computeContext.computeEncoder.setBuffer(vertexBuffer, offset: 0, index: 1)
        // Pass the height map to the compute shader.
        computeContext.computeEncoder.setTexture(heightMap.heightMapTexture.read(), index: 2)
        
        // Dispatch the compute shader.
        computeContext.computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    /// Updates the height map mesh by generating a height map, deriving normals from it, and then setting the vertex positions and normals.
    func update(computeContext: ComputeUpdateContext) {
        // Set up the height map compute params.
        let heightMapComputeParams = HeightMapComputeParams(threadgroups: threadgroups,
                                                            threadsPerThreadgroup: threadsPerThreadgroup,
                                                            dimensions: dimensions,
                                                            size: size,
                                                            cellSize: cellSize,
                                                            isInteractionHappening: isInteractionHappening,
                                                            interactionPosition: interactionPosition)
        
        // Generate the height map height values.
        heightMap.generateHeight(computeContext: computeContext, heightMapComputeParams: heightMapComputeParams)
        // Update the height map normal directions.
        heightMap.updateNormals(computeContext: computeContext, heightMapComputeParams: heightMapComputeParams)
        
        // Update the vertex positions and normals.
        updateVertices(computeContext: computeContext)
    }
}
