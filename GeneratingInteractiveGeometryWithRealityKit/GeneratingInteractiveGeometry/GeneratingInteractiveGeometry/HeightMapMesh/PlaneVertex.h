/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure containing the description of a plane mesh vertex.
*/

#pragma once

#include <simd/simd.h>

struct PlaneVertex {
    simd_float3 position;
    simd_float3 normal;
};
