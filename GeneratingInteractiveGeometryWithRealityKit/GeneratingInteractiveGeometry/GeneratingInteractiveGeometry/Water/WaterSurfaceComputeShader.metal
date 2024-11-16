/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Compute functions for simulating the surface of water using a height map.
*/

#include <metal_stdlib>

using namespace metal;

#include "../Compute/Helpers.h"
#include "WaterParams.h"

/// Resets the water surface by zeroing out the height map and velocity map textures.
[[kernel]]
void resetWaterSurface(constant WaterParams &params [[buffer(0)]],
                       texture2d<float, access::write> heightMap [[texture(1)]],
                       texture2d<float, access::write> velocityMap [[texture(2)]],
                       uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= params.dimensions)) { return; }

    // Reset the height map, elevating the water slightly above a height of zero
    // so that it has room to experience downward disturbances.
    heightMap.write(0.01, pixelCoords);  // Optional: Comment out this line to preserve the height from the other generators.
    // Reset the velocity map.
    velocityMap.write(0, pixelCoords);
}

/// Disturbs the water surface by increasing/decreasing the water height around the disturbance position.
[[kernel]]
void disturbWaterSurface(constant WaterParams &params [[buffer(0)]],
                         texture2d<float, access::read> heightMapIn [[texture(1)]],
                         texture2d<float, access::write> heightMapOut [[texture(2)]],
                         uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= params.dimensions)) { return; }

    // Get the current state of the height map.
    float4 heightMapData = heightMapIn.read(pixelCoords);
    
    // Convert the position of the current pixel to the same coordinate space as the disturbance position.
    float2 currentPosition = float2(remap(pixelCoords.x, float2(0, params.dimensions.x - 1), float2(-params.size.x / 2, params.size.x / 2)),
                                    remap(pixelCoords.y, float2(0, params.dimensions.y - 1), float2(-params.size.y / 2, params.size.y / 2)));
    // Disturb the height of the water closer to the disturbance position.
    float distance = length(currentPosition-params.disturbancePosition);
    if (distance <= params.disturbanceRadius) {
        heightMapData.a -= params.disturbanceAmount * pow((params.disturbanceRadius-distance)/(params.disturbanceRadius), 2);
    }
    
    // Write modified height map data back to the height map.
    heightMapOut.write(heightMapData, pixelCoords);
}

/// Updates the water velocity in each cell, increasing it if there is more water surrounding the cell than inside it (simulates water pouring into the cell),
/// and decreasing it if there is more water in the cell than surrounding it (simulates water pouring out of the cell).
[[kernel]]
void updateWaterVelocity(constant WaterParams &params [[buffer(0)]],
                         texture2d<float, access::read> heightMapIn [[texture(1)]],
                         texture2d<float, access::read> velocityMapIn [[texture(2)]],
                         texture2d<float, access::write> velocityMapOut [[texture(3)]],
                         uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= params.dimensions)) { return; }

    // Sample the current grid cell water height along with its four neighbors.
    uint2 pixelCoordsMinusOne = max(pixelCoords, 1) - 1;  // Current pixel coordinate minus one in both dimensions, guaranteed to be in bounds.
    uint2 pixelCoordsPlusOne = min(pixelCoords + 1, params.dimensions - 1);  // Current pixel coordinate plus one in both dimensions, guaranteed to be in bounds.
    float height = heightMapIn.read(pixelCoords).a;
    float leftHeight = heightMapIn.read(uint2(pixelCoordsMinusOne.x, pixelCoords.y)).a;
    float rightHeight = heightMapIn.read(uint2(pixelCoordsPlusOne.x, pixelCoords.y)).a;
    float bottomHeight = heightMapIn.read(uint2(pixelCoords.x, pixelCoordsMinusOne.y)).a;
    float topHeight = heightMapIn.read(uint2(pixelCoords.x, pixelCoordsPlusOne.y)).a;
    
    // Determine the acceleration of water into the current grid cell.
    float speedFactor = (params.waterSpeed * params.waterSpeed) / (params.cellSize.x * params.cellSize.y);
    float acceleration = speedFactor * (leftHeight + rightHeight + bottomHeight + topHeight - 4.0 * height);
    
    // Update the water velocity.
    float velocity = velocityMapIn.read(pixelCoords).r;
    velocity += acceleration * params.deltaTime;
    velocityMapOut.write(0.9975 * velocity, pixelCoords);  // Dampen the velocity.
}

/// Updates the water height using the velocity map.
[[kernel]]
void updateWaterHeight(constant WaterParams &params [[buffer(0)]],
                       texture2d<float, access::read> velocityMap [[texture(1)]],
                       texture2d<float, access::read> heightMapIn [[texture(2)]],
                       texture2d<float, access::write> heightMapOut [[texture(3)]],
                       uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= params.dimensions)) { return; }

    // Sample the current height and velocity.
    float4 heightMapData = heightMapIn.read(pixelCoords);
    float height = heightMapData.a;
    float velocity = velocityMap.read(pixelCoords).r;
    
    // Update the height using the velocity.
    height += velocity * params.deltaTime;
    heightMapOut.write(float4(heightMapData.xyz, height), pixelCoords);
}
