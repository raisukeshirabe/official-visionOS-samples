/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Components and enum for audio materials.
*/

import RealityKit

struct AudioMaterialComponent: Component {
    var material: AudioMaterial
}

struct AudioMaterialLookupComponent: Component {
    var audioMaterialPerFace: [AudioMaterial]
}

enum AudioMaterial: String, CaseIterable, CustomStringConvertible {

    case none
    case plastic
    case rock
    case metal
    case wood
    case glass
    case concrete
    case fabric

    var description: String { rawValue.capitalized }
}
