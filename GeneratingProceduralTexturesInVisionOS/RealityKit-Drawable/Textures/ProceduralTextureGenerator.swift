/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure to generate a random texture.
*/

import SwiftUI
import RealityKit
import GameplayKit

/// A structure to generate a random texture.
struct ProceduralTextureGenerator {
    /// Generate a texture with the seed.
    static func generate(_ seed: Int) throws -> TextureResource {
        /// The overall length of the texture.
        let length = 1024
        
        /// The number of bytes that compose a single pixel.
        let bytesPerPixel = 1

        /// The number of bits that are in a byte.
        let bitSize = 8

        /// The generator to randomly generate numbers.
        let generator = GKARC4RandomSource()

        /// Assign the generator seed that determines the random source’s behavior.
        guard let setSeed = "\(seed)".data(using: .ascii) else {
            throw ProceduralTextureGeneratorError.convertSeedFailed
        }
        generator.seed = setSeed

        /// The array to hold the pixels.
        var pixels: [UInt8] = Array(repeating: 0, count: length * length)

        // Randomly assign the array with 255 or 0 with the generator.
        for pixel in 0..<pixels.count {
            pixels[pixel] = (generator.nextUniform() < 0.5 ? 255 : 0)
        }

        /// The data provider for the creation of the bitmap image.
        guard let provider = CGDataProvider(
            data: Data(bytes: &pixels, count: pixels.count * bytesPerPixel) as CFData
        ) else {
            throw ProceduralTextureGeneratorError.providerCreationFailed
        }

        /// The source image for the texture.
        guard let image = CGImage(
            width: length,
            height: length,
            bitsPerComponent: bytesPerPixel * bitSize,
            bitsPerPixel: bytesPerPixel * bitSize,
            bytesPerRow: length * bytesPerPixel,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            throw ProceduralTextureGeneratorError.imageCreationFailed
        }
        
        // Attempt to create and return a `TextureResource` with the image.
        return try TextureResource(image: image, options: TextureResource.CreateOptions(semantic: .color))
    }
}

/// The errors that can occur in the setup of `ProceduralTextureGenerator`.
enum ProceduralTextureGeneratorError: Error {
    /// The seed fails to convert to `Data`.
    case convertSeedFailed
    /// The provider fails to create.
    case providerCreationFailed
    /// The image fails to create.
    case imageCreationFailed
}
