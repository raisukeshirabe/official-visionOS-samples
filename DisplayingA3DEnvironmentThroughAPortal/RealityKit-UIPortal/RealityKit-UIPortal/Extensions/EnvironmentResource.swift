/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension of the environment resource class to create an environment resource from an image URL.
*/

import RealityKit
import Foundation
import CoreImage

extension EnvironmentResource {
    /// Asynchronously generates an environment resource from an image URL.
    convenience init(fromImage url: URL) async throws {
        // Reads the image source from the URL.
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            fatalError("Failed to load image from \(url)")
        }

        // Create an image object with the image source.
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            fatalError("Failed to load image from \(url)")
        }

        // Creates the environment resource with the image.
        try await self.init(equirectangular: image)
    }
}
