/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Compute functions for generating a height map from a terrain height map texture and adding height to a height map using a height brush texture.
*/

#include <metal_stdlib>

using namespace metal;

#include "../Compute/Helpers.h"
#include "TerrainParams.h"

/// Resets the height map to reflect the terrain height map texture.
[[kernel]]
void resetTerrainHeightMap(constant TerrainParams &params [[buffer(0)]],
                            texture2d<float, access::sample> terrainHeightMap [[texture(1)]],
                            texture2d<float, access::write> heightMap [[texture(2)]],
                            uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= params.dimensions)) { return; }

    // Convert the pixel coordinates to texture coordinates.
    float2 uv = float2(pixelCoords) / (float2(params.dimensions) - 1);
    uv.y = 1 - uv.y;  // Flip the y-coordinate, by subtracting the normalized uv.y coordinate from 1, because the `MTLTexture` has its origin in the top left corner.
    // Sample terrain height.
    constexpr sampler bilinearSampler (coord::normalized, address::clamp_to_edge, filter::linear);
    float height = terrainHeightMap.sample(bilinearSampler, uv).r / 2;

    // Write height to height map.
    heightMap.write(height, pixelCoords);
}

/// Adds height to the height map using the given height brush texture.
[[kernel]]
void addHeightToTerrainHeightMap(constant TerrainParams &params [[buffer(0)]],
                                 texture2d<float, access::sample> heightBrush [[texture(1)]],
                                 texture2d<float, access::read> heightMapIn [[texture(2)]],
                                 texture2d<float, access::write> heightMapOut [[texture(3)]],
                                 uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= params.dimensions)) { return; }
    
    // Get the current state of the height map.
    float4 heightMapData = heightMapIn.read(pixelCoords);

    // Convert the position of the current pixel to the same coordinate space as the brush position.
    float2 currentPosition = float2(remap(pixelCoords.x, float2(0, params.dimensions.x - 1), float2(-params.size.x / 2, params.size.x / 2)),
                                    remap(pixelCoords.y, float2(0, params.dimensions.y - 1), float2(-params.size.y / 2, params.size.x / 2)));
    
    // Get the uv coordinates at which to sample the brush texture given the current position.
    float2 brushToCurrentPosition = currentPosition - params.brushPosition;
    float2 uvBrush = float2(remap(brushToCurrentPosition.x, float2(-params.brushSize / 2, params.brushSize / 2), float2(0, 1)),
                            remap(brushToCurrentPosition.y, float2(-params.brushSize / 2, params.brushSize / 2), float2(1, 0)));
    
    // Add height when within the brush's zone of influence.
    // This is true if the brush uvs are in the range [0, 1].
    if (all(uvBrush >= 0) && all(uvBrush <= 1)) {
        // Sample the brush texture.
        constexpr sampler bilinearSampler (coord::normalized, address::repeat, filter::linear);
        float brushHeight = heightBrush.sample(bilinearSampler, uvBrush).r;
        
        // Add the brush height to the height map.
        heightMapData.a += params.brushInfluence * brushHeight;
    }
    
    // Write the height map data back to the height map.
    heightMapOut.write(heightMapData, pixelCoords);
}
