/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A compute function that generates a height map in the shape of a sine wave moving outward from the center of the texture.
*/

#include <metal_stdlib>

using namespace metal;

/// Generates a height map in the shape of a sine wave moving outward from the center of the texture.
[[kernel]]
void generateSineWaveHeightMap(texture2d<float, access::read> heightMapIn [[texture(0)]],
                               texture2d<float, access::write> heightMapOut [[texture(1)]],
                               constant float &time [[buffer(2)]],
                               constant float &amplitude [[buffer(3)]],
                               uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (pixelCoords.x >= heightMapIn.get_width() || pixelCoords.y >= heightMapIn.get_height()) { return; }
    
    // Compute texture coordinates ranging from 0 to 1 along each axis.
    float2 uv = float2(pixelCoords.x / (heightMapIn.get_width() - 1.0),
                       pixelCoords.y / (heightMapIn.get_height() - 1.0));
    
    // Get the distance to the center of the texture in texture coordinate space.
    float distanceToCenter = length(uv - 0.5);
    // Normalize the distance to a range from 0 to 2π along the horizontal and vertical axes.
    float normalizedDistanceToCenter = (distanceToCenter / 0.5) * (2 * M_PI_F);

    // Get sine as a function of the normalized distance to the center of the texture times the wave count,
    // subtracting time to animate it outward over time.
    float waveCount = 3;
    float sine = sin(normalizedDistanceToCenter * waveCount - time);
    // Convert sine to the range 0 to 1.
    float sine01 = (sine + 1) / 2;
    
    // Generate height from the sine function.
    float height = amplitude * sine01;
    
    // Read the current height map data.
    float4 heightMapData = heightMapIn.read(pixelCoords);
    // Update the alpha channel with the new height.
    heightMapData.a = height;
    // Write the updated height data to height map.
    heightMapOut.write(heightMapData, pixelCoords);
}
