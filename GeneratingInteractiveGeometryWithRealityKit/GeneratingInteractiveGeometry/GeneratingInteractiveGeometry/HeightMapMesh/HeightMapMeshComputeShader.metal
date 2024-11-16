/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Compute functions for deriving normal directions from a height map and populating the vertex attributes of a height map mesh.
*/

#include <metal_stdlib>

using namespace metal;

#include "PlaneVertex.h"
#include "MeshParams.h"

/// Derives normal directions from a height map, storing them in the texture's RGB channels.
[[kernel]]
void deriveNormalsFromHeightMap(texture2d<float, access::read> heightMapIn [[texture(0)]],
                                texture2d<float, access::write> heightMapOut [[texture(1)]],
                                constant float2 &cellSize [[buffer(2)]],
                                uint2 pixelCoords [[thread_position_in_grid]]) {
    // Get the dimensions of the height map.
    uint2 dimensions = uint2(heightMapIn.get_width(), heightMapIn.get_height());
    
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= dimensions)) { return; }
    
    // The current pixel coordinate minus one in both dimensions, guaranteed to be in bounds.
    uint2 pixelCoordsMinusOne = max(pixelCoords, 1) - 1;
    // The current pixel coordinate plus one in both dimensions, guaranteed to be in bounds.
    uint2 pixelCoordsPlusOne = min(pixelCoords + 1, dimensions - 1);
    
    // Sample the current pixel along with its four neighbors.
    float height = heightMapIn.read(pixelCoords).a;
    float leftHeight = heightMapIn.read(uint2(pixelCoordsMinusOne.x, pixelCoords.y)).a;
    float rightHeight = heightMapIn.read(uint2(pixelCoordsPlusOne.x, pixelCoords.y)).a;
    float bottomHeight = heightMapIn.read(uint2(pixelCoords.x, pixelCoordsMinusOne.y)).a;
    float topHeight = heightMapIn.read(uint2(pixelCoords.x, pixelCoordsPlusOne.y)).a;
    
    // Compute the normal direction using central differences.
    float3 normal = normalize(float3((leftHeight - rightHeight) / (cellSize.x * 2),
                                     (bottomHeight - topHeight) / (cellSize.y * 2),
                                     1));
    
    // Write the normal direction to the height map.
    heightMapOut.write(float4(normal, height), pixelCoords);
}

/// Sets vertex positions and normals by reading height map data.
[[kernel]]
void setVertexData(constant MeshParams &params [[buffer(0)]],
                   device PlaneVertex *vertices [[buffer(1)]],
                   texture2d<float, access::read> heightMap [[texture(2)]],
                   uint2 vertexCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(vertexCoords >= params.dimensions)) { return; }
    
    // Calculate the 1D vertex buffer index given its 2D x, y coordinates.
    uint vertexIndex = vertexCoords.x + params.dimensions.x * vertexCoords.y;
    // Get the current vertex.
    device PlaneVertex &vert = vertices[vertexIndex];
    
    // Sample the height map pixel corresponding to this vertex.
    float4 heightMapData = heightMap.read(vertexCoords);
    // Extract the normal direction and the height.
    float3 normal = heightMapData.rgb;
    float height = heightMapData.a;
    
    // Convert the x and y vertex coordinates to the range [0, 1].
    float2 vertexCoords01 = float2(vertexCoords) / float2(params.dimensions - 1);
    
    // Get the x and y position from the size.
    float2 xyPosition = params.size * vertexCoords01 - params.size / 2;
    // Get the z position from the height, clamping it within
    // the bounds of the mesh that `maxVertexDepth` defines.
    float zPosition = clamp(height, 0., params.maxVertexDepth);
    
    // Update the vertex position and normal.
    vert.position = float3(xyPosition, zPosition);
    vert.normal = normal;
}
