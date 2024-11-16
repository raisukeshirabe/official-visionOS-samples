/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A collection of compute utility methods to assist in the creation of command queues and compute pipelines.
*/

import Metal

/// The device Metal selects as the default.
let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

/// Makes a command queue with the given label.
func makeCommandQueue(labeled label: String) -> MTLCommandQueue? {
    guard let queue = metalDevice?.makeCommandQueue() else {
        return nil
    }
    queue.label = label
    return queue
}

/// Makes a compute pipeline for the compute function with the given name.
func makeComputePipeline(named name: String) -> MTLComputePipelineState? {
    guard let function = metalDevice?.makeDefaultLibrary()?.makeFunction(name: name) else {
        return nil
    }
    return try? metalDevice?.makeComputePipelineState(function: function)
}
