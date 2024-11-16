/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure that generates a low-level mesh suitable for containing the geometry of a 2D plane.
*/

import RealityKit

@MainActor
struct PlaneMesh {
    /// The plane low-level mesh.
    var mesh: LowLevelMesh!
    /// The size of the plane mesh.
    let size: SIMD2<Float>
    /// The number of vertices in each dimension of the plane mesh.
    let dimensions: SIMD2<UInt32>
    /// The maximum offset depth for the vertices of the plane mesh.
    ///
    /// Use this to ensure the bounds of the plane encompass its vertices, even if they are offset.
    let maxVertexDepth: Float
    
    /// Creates a low-level mesh with `PlaneVertex` vertices.
    private func createMesh() throws -> LowLevelMesh {
        // Define the vertex attributes of `PlaneVertex`.
        let positionAttributeOffset = MemoryLayout.offset(of: \PlaneVertex.position) ?? 0
        let normalAttributeOffset = MemoryLayout.offset(of: \PlaneVertex.normal) ?? 16
        
        let positionAttribute = LowLevelMesh.Attribute(semantic: .position, format: .float3, offset: positionAttributeOffset)
        let normalAttribute = LowLevelMesh.Attribute(semantic: .normal, format: .float3, offset: normalAttributeOffset)
        
        let vertexAttributes = [positionAttribute, normalAttribute]
        
        // Define the vertex layouts of `PlaneVertex`.
        let vertexLayouts = [LowLevelMesh.Layout(bufferIndex: 0, bufferStride: MemoryLayout<PlaneVertex>.stride)]
        
        // Derive the vertex and index counts from the dimensions.
        let vertexCount = Int(dimensions.x * dimensions.y)
        let indicesPerTriangle = 3
        let trianglesPerCell = 2
        let cellCount = Int((dimensions.x - 1) * (dimensions.y - 1))
        let indexCount = indicesPerTriangle * trianglesPerCell * cellCount
        
        // Create a low-level mesh with the necessary `PlaneVertex` capacity.
        let meshDescriptor = LowLevelMesh.Descriptor(vertexCapacity: vertexCount,
                                                     vertexAttributes: vertexAttributes,
                                                     vertexLayouts: vertexLayouts,
                                                     indexCapacity: indexCount)
        return try LowLevelMesh(descriptor: meshDescriptor)
    }
    
    /// Converts a 2D vertex coordinate to a 1D vertex buffer index.
    private func vertexIndex(_ xCoord: UInt32, _ yCoord: UInt32) -> UInt32 {
        xCoord + dimensions.x * yCoord
    }
    
    /// Initialize the vertices of the mesh, positioning them to form an xy-plane with the given size.
    private func initializeVertexData() {
        // Initialize mesh vertex positions and normals.
        mesh.withUnsafeMutableBytes(bufferIndex: 0) { rawBytes in
            // Convert `rawBytes` into a `PlaneVertex` buffer pointer.
            let vertices = rawBytes.bindMemory(to: PlaneVertex.self)
            
            // Define the normal direction for the vertices.
            let normalDirection: SIMD3<Float> = [0, 0, 1]
            
            // Iterate through each vertex.
            for xCoord in 0..<dimensions.x {
                for yCoord in 0..<dimensions.y {
                    // Remap the x and y vertex coordinates to the range [0, 1].
                    let xCoord01 = Float(xCoord) / Float(dimensions.x - 1)
                    let yCoord01 = Float(yCoord) / Float(dimensions.y - 1)
                    
                    // Derive the vertex position from the remapped vertex coordinates and the size.
                    let xPosition = size.x * xCoord01 - size.x / 2
                    let yPosition = size.y * yCoord01 - size.y / 2
                    let zPosition = Float(0)
                    
                    // Get the current vertex from the vertex coordinates and set its position and normal.
                    let vertexIndex = Int(vertexIndex(xCoord, yCoord))
                    vertices[vertexIndex].position = [xPosition, yPosition, zPosition]
                    vertices[vertexIndex].normal = normalDirection
                }
            }
        }
    }
    
    /// Initializes the indices of the mesh, two triangles at a time, for each cell in the mesh.
    private func initializeIndexData() {
        mesh.withUnsafeMutableIndices { rawIndices in
            // Convert `rawIndices` into a UInt32 pointer.
            guard var indices = rawIndices.baseAddress?.assumingMemoryBound(to: UInt32.self) else { return }
            
            // Iterate through each cell.
            for xCoord in 0..<dimensions.x - 1 {
                for yCoord in 0..<dimensions.y - 1 {
                    /*
                       Each cell in the plane mesh consists of two triangles:
                        
                                  topLeft     topRight
                                         |\ ̅ ̅|
                         1st Triangle--> | \ | <-- 2nd Triangle
                                         | ̲ ̲\|
                      +y       bottomLeft     bottomRight
                       ^
                       |
                       *---> +x
                     
                     */
                    let bottomLeft = vertexIndex(xCoord, yCoord)
                    let bottomRight = vertexIndex(xCoord + 1, yCoord)
                    let topLeft = vertexIndex(xCoord, yCoord + 1)
                    let topRight = vertexIndex(xCoord + 1, yCoord + 1)
                    
                    // Create the 1st triangle with a counterclockwise winding order.
                    indices[0] = bottomLeft
                    indices[1] = bottomRight
                    indices[2] = topLeft
                    
                    // Create the 2nd triangle with a counterclockwise winding order.
                    indices[3] = topLeft
                    indices[4] = bottomRight
                    indices[5] = topRight
                    
                    indices += 6
                }
            }
        }
    }
    
    /// Initializes mesh parts, indicating topology and bounds.
    func initializeMeshParts() {
        // Create a bounding box that encompasses the plane's size and max vertex depth.
        let bounds = BoundingBox(min: [-size.x / 2, -size.y / 2, 0],
                                 max: [size.x / 2, size.y / 2, maxVertexDepth])
        
        mesh.parts.replaceAll([LowLevelMesh.Part(indexCount: mesh.descriptor.indexCapacity,
                                                 topology: .triangle,
                                                 bounds: bounds)])
    }
    
    /// Initializes the plane mesh by creating a low-level mesh and filling its vertex and index buffers
    /// to form a plane with given size and dimensions.
    init(size: SIMD2<Float>, dimensions: SIMD2<UInt32>, maxVertexDepth: Float = 1) throws {
        self.size = size
        self.dimensions = dimensions
        self.maxVertexDepth = maxVertexDepth
        
        // Create the low-level mesh.
        self.mesh = try createMesh()

        // Fill the mesh's vertex buffer with data.
        initializeVertexData()
        
        // Fill the mesh's index buffer with data.
        initializeIndexData()
        
        // Initialize the mesh parts.
        initializeMeshParts()
    }
}
