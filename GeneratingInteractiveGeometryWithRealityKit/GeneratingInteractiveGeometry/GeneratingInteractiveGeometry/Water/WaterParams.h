/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure containing water parameters for the generation of an interactive water surface height map.
*/


#pragma once

#include <simd/simd.h>

struct WaterParams {
    float deltaTime;
    float waterSpeed;
    simd_float2 disturbancePosition;
    float disturbanceRadius;
    float disturbanceAmount;
    simd_uint2 dimensions;
    simd_float2 size;
    simd_float2 cellSize;
};
