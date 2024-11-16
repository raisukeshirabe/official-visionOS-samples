/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Definition of helper methods for use in Metal compute shaders.
*/

#pragma once

/// Remaps a value from one range to another.
float remap(float value, float2 fromRange, float2 toRange);
