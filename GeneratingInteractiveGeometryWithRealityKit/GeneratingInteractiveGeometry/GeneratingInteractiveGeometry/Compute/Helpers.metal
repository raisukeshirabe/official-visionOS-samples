/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Implementation of helper methods for use in Metal compute shaders.
*/

#include <metal_stdlib>

using namespace metal;

#include "Helpers.h"

/// Remaps a value from one range to another.
float remap(float value, float2 fromRange, float2 toRange) {
   return toRange.x + (value - fromRange.x) * (toRange.y - toRange.x) / (fromRange.y - fromRange.x);
}
