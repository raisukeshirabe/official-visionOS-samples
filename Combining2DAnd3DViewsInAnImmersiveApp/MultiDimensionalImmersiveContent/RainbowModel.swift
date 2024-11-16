/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The data model for entities.
*/
 
import SwiftUI
import RealityKit

// MARK: RainbowModel
/// A model containing data to assign to the created entities for the rainbow.
@Observable
class RainbowModel {
    // MARK: - Properties
    /// An array of the data to use for entities you add as attachments.
    var archAttachments: [ArchAttachment] = [
        /// A SwiftUI arch with orange color.
        ArchAttachment(title: .orange),
        /// A SwiftUI arch with red color.
        ArchAttachment(title: .red),
        /// A SwiftUI arch with pink color.
        ArchAttachment(title: .pink),
        /// A SwiftUI arch with blue color.
        ArchAttachment(title: .blue)
]
    
    /// An array of the attachments to add for a tap gesture.
    var tapAttachments: [CloudTapAttachment] = []
    
    /// A Reality Composer Pro plane, from an asset creator, that is a physically based material with dark green color.
    var plane = EntityData(title: "plane")
    
    /// An array of the data for arches to load from Reality Composer Pro.
    var realityKitAssets: [EntityData] = [
        /// A Reality Composer Pro arch, from an asset creator, that is a custom shader graph material with green color.
        EntityData(title: "green"),
        /// A Reality Composer Pro arch, from an asset creator, that is a simple metallic material with yellow color.
        EntityData(title: "yellow", simpleMaterial: .init(color: .yellow, isMetallic: true))
    ]
}

// MARK: - Entity data
/// Represents the properites of each entity.
struct EntityData: Identifiable {
    let id = UUID()
    var title: String
    var simpleMaterial: SimpleMaterial? = nil
}

/// An enumeration that provides the type of view to create an attachment for.
enum ArchAttachmentColor: String {
    case orange, pink, blue, red
}

/// Stores the position and scale of each attachment.
struct ArchAttachment: Identifiable {
    let id = UUID()
    var title: ArchAttachmentColor
    var position: SIMD3<Float> = .zero
    var scale: SIMD3<Float> = .one
}

/// Stores the position and the root entity of each cloud attachment.
struct CloudTapAttachment: Identifiable {
    let id = UUID()
    let position: SIMD3<Float>
    let parent: Entity?
}
