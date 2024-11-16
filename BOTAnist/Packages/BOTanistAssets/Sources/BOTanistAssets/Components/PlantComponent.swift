/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A component that marks an entity as a plant.
*/

import Foundation
import RealityKit

public struct PlantComponent: Component, Codable {
    public enum PlantTypeKey: String, CaseIterable, Identifiable, Codable, Sendable {
        case coffeeBerry
        case poppy
        case yucca
        
        public var id: Self { self }
    }
    
    public var interactedWith: Bool = false
    
    public var plantType: PlantTypeKey = .coffeeBerry
    
    public init() {
        
    }
}
