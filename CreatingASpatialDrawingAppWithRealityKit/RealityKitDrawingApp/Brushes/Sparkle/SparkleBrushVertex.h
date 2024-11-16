/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Vertex data for the sparkle brush style, written in Metal Shading Language.
*/

#pragma once

#include "../../Utilities/MetalPacking.h"
#include <simd/simd.h>

// Vertex attribute data must respect size and alignment requirements in Metal Shading Language.
// See Table 2.4, "Size and alignment of packed vector data types" in the Metal Shading Language Specification.
#pragma pack(push, 4)
struct SparkleBrushAttributes {
    packed_float3 position;
    packed_half3 color;
    float curveDistance;
    float size;
};

struct SparkleBrushParticle {
    struct SparkleBrushAttributes attributes;
    packed_float3 velocity;
};

struct SparkleBrushVertex {
    struct SparkleBrushAttributes attributes;
    simd_half2 uv;
};

struct SparkleBrushSimulationParams {
    uint32_t particleCount;
    float deltaTime;
    float dragCoefficient;
};
#pragma pack(pop)

static_assert(sizeof(struct SparkleBrushAttributes) == 28, "ensure packing");
static_assert(sizeof(struct SparkleBrushParticle) == 40, "ensure packing");
static_assert(sizeof(struct SparkleBrushVertex) == 32, "ensure packing");
static_assert(sizeof(struct SparkleBrushSimulationParams) == 12, "ensure packing");
