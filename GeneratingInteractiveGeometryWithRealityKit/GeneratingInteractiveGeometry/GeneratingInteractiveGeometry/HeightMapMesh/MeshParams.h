/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure containing the description of a plane mesh for use in Metal compute shaders.
*/

#pragma once

#include <simd/simd.h>

struct MeshParams {
    simd_uint2 dimensions;
    simd_float2 size;
    float maxVertexDepth;
};
