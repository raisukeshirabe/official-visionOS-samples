/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Vertex data for the solid brush type, defined in Metal Shading Language.
*/

//
//  SolidBrushVertex.h
//

#pragma once

#include "../../Utilities/MetalPacking.h"

// Vertex attribute data must respect size and alignment requirements in Metal Shading Language.
// See Table 2.4, "Size and alignment of packed vector data types" in the Metal Shading Language Specification.
#pragma pack(push, 4)
struct SolidBrushVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float3 bitangent;
    packed_float2 materialProperties; // X = Roughness, Y = Metallic
    float curveDistance;
    packed_half3 color;
};
#pragma pack(pop)

static_assert(sizeof(struct SolidBrushVertex) == 56, "ensure packing");
