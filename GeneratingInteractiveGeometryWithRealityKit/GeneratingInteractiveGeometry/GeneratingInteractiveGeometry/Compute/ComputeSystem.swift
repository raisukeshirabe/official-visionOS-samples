/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A system for passing command buffers and compute command encoders to structures dispatching compute commands in every frame.
*/

import Metal
import RealityKit

/// A structure containing the context a `ComputeSystem` needs to dispatch compute commands in every frame.
struct ComputeUpdateContext {
    /// The number of seconds elapsed since the last frame.
    let deltaTime: TimeInterval
    /// The command buffer for the current frame.
    let commandBuffer: MTLCommandBuffer
    /// The compute command encoder for the current frame.
    let computeEncoder: MTLComputeCommandEncoder
}

/// A protocol that enables its adoptees to dispatch their own compute commands in every frame.
protocol ComputeSystem {
    @MainActor
    func update(computeContext: ComputeUpdateContext)
}

/// A component that contains a `ComputeSystem`.
struct ComputeSystemComponent: Component {
    let computeSystem: ComputeSystem
}

/// A class that updates the `ComputeSystem` of each `ComputeSystemComponent` with `ComputeUpdateContext` in every frame.
class ComputeDispatchSystem: System {
    /// The application's command queue.
    ///
    /// A single, global command queue to use throughout the entire application.
    static let commandQueue: MTLCommandQueue? = makeCommandQueue(labeled: "Compute Dispatch System Command Queue")
    
    /// The query this system uses to get all entities with a `ComputeSystemComponent` in every frame.
    let query = EntityQuery(where: .has(ComputeSystemComponent.self))
    
    required init(scene: Scene) { }
    
    /// Updates all compute systems with the current frame's `ComputeUpdateContext`.
    func update(context: SceneUpdateContext) {
        // Get all entities with a `ComputeSystemComponent` in every frame.
        let computeSystemEntities = context.entities(matching: query, updatingSystemWhen: .rendering)
        
        // Create the command buffer and compute encoder responsible for dispatching all compute commands this frame.
        guard let commandBuffer = Self.commandQueue?.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        // Enqueue the command buffer.
        commandBuffer.enqueue()
        
        // Dispatch all compute systems to encode their compute commands.
        let computeContext = ComputeUpdateContext(deltaTime: context.deltaTime,
                                                  commandBuffer: commandBuffer,
                                                  computeEncoder: computeEncoder)
        for computeSystemEntity in computeSystemEntities {
            if let computeSystemComponent = computeSystemEntity.components[ComputeSystemComponent.self] {
                computeSystemComponent.computeSystem.update(computeContext: computeContext)
            }
        }
        
        // Stop encoding compute commands and commit them to run on the GPU.
        computeEncoder.endEncoding()
        commandBuffer.commit()
    }
}
