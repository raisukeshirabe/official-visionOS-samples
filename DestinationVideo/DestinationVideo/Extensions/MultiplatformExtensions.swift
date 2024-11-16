/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Helper extensions that simplify multiplatform development.
*/

import Foundation

#if os(macOS)
import AppKit
public typealias PlatformImage = NSImage

extension NSImage {
    var cgImage: CGImage? {
        var rect = CGRect(origin: .zero, size: size)
        return cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }
}
#else
import UIKit
public typealias PlatformImage = UIImage
#endif

extension PlatformImage {
    var imageData: Data? {
        #if os(macOS)
        tiffRepresentation
        #else
        pngData()
        #endif
    }
}
