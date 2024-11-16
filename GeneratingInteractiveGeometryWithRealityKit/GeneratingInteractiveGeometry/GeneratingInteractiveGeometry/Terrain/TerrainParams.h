/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure containing terrain parameters for the construction and interactive editing of a terrain height map.
*/

#pragma once

#include <simd/simd.h>

struct TerrainParams {
    simd_float2 brushPosition;
    float brushSize;
    float brushInfluence;
    simd_uint2 dimensions;
    simd_float2 size;
};
