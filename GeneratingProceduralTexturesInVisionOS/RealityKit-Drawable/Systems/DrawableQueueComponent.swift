/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A component that allows for entites to generate textures to update over time.
*/

import SwiftUI
import RealityKit

/// The component that takes in a new texture and
/// updates it over time.
struct DrawableQueueComponent: Component {
    /// The texture to use for the update.
    var texture: TextureResource
    
    /// The Metal texture representation of the resource.
    var mtlTexture: MTLTexture
    
    /// The Metal command queue to handle requests for the GPU.
    let mtlCommandQueue: MTLCommandQueue
    
    /// The Metal configuration to allow GPU to process.
    let pipeState: MTLComputePipelineState

    /// The amount of time that passes.
    var time: TimeInterval = 0

    init(texture: TextureResource) throws {
        // Register the system to handle the component.
        DrawableQueueSystem.registerSystem()

        // Set the input texture.
        self.texture = texture

        /// The system default device.
        guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
            throw DrawableComponentError.deviceCreationFailed
        }
        
        /// The descriptor to configure new Metal texture objects.
        let desc = MTLTextureDescriptor()
        desc.width = texture.width
        desc.height = texture.height
        desc.usage = [.shaderWrite, .shaderRead]
        desc.pixelFormat = .r16Float

        // Create the Metal texture by passing the descriptor.
        guard let newTexture = mtlDevice.makeTexture(descriptor: desc) else {
            throw DrawableComponentError.textureCreationFailed
        }
        self.mtlTexture = newTexture

        // Copy the input texture to the Metal texture.
        try texture.copy(to: mtlTexture)

        /// The descriptor for the drawable queue.
        let queueDesc = TextureResource.DrawableQueue.Descriptor(
            pixelFormat: .rgba16Float,
            width: texture.width,
            height: texture.height,
            usage: [.shaderRead, .shaderWrite],
            mipmapsMode: .none
        )

        // Replace the texture with the result of the drawable queue.
        guard let queue = try? TextureResource.DrawableQueue(queueDesc) else {
            throw DrawableComponentError.queueCreationFailed
        }
        texture.replace(withDrawables: queue)

        /// The name of the shader function.
        let shaderFunctionName: String = "textureShader"

        // Assign the configuration with the shader function.
        guard let library = mtlDevice.makeDefaultLibrary(), let function = library.makeFunction(name: shaderFunctionName) else {
            throw DrawableComponentError.shaderFunctionCreationFailed
        }
        self.pipeState = try mtlDevice.makeComputePipelineState(function: function)

        // Assign the Metal command queue.
        guard let newQueue = mtlDevice.makeCommandQueue() else {
            throw DrawableComponentError.commandQueueCreationFailed
        }
        self.mtlCommandQueue = newQueue
    }

    /// Update the texture, allowing values and contents to change over time.
    mutating func update(deltaTime: TimeInterval) {
        // Increment the value of time with amount of time.
        time += deltaTime
        
        /// The next drawable, the command buffer, and a compute command encoder.
        guard let drawable = try? texture.drawableQueue?.nextDrawable(),
            let commandBuffer = mtlCommandQueue.makeCommandBuffer(),
            let encoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }

        // Attach the pipe state to the encoder.
        encoder.setComputePipelineState(pipeState)
        
        /// The time that passes, in a `Float` format.
        var timeArg: Float = Float(time)
        
        // Pass the time, set the texture, and set the drawable texture to the `Metal` shader encoder.
        encoder.setBytes(&timeArg, length: MemoryLayout<Float>.stride, index: 0)
        encoder.setTexture(mtlTexture, index: 0)
        encoder.setTexture(drawable.texture, index: 1)
        
        /// The size of each thread group.
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        
        /// The number of the thread group for the texture.
        let threadGroups = MTLSizeMake(
            texture.width / threadGroupCount.width,
            texture.height / threadGroupCount.height,
            1
        )
        
        // Dispatch a compute dispatch command.
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        
        // Declare that all command generation is complete.
        encoder.endEncoding()
        
        // Submits the command buffer to run on the GPU.
        commandBuffer.commit()
        
        // Presents the updated texture to the renderer.
        drawable.present()
    }
}

/// The errors that can occur in the setup of `DrawableQueueComponent`.
enum DrawableComponentError: Error {
    /// The `Metal` device creation fails.
    case deviceCreationFailed
    /// The `Metal` texture creation fails.
    case textureCreationFailed
    /// The drawable queue creation fails.
    case queueCreationFailed
    /// The shader function creation fails.
    case shaderFunctionCreationFailed
    /// The pipline state creation fails.
    case pipelineStateCreationFailed
    /// The command queue creation fails.
    case commandQueueCreationFailed
}
