/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The state of the current drag gesture.
*/

import Foundation

struct DragState {
    var draggedObject: PlacedObject
    var initialPosition: SIMD3<Float>
    
    @MainActor
    init(objectToDrag: PlacedObject) {
        draggedObject = objectToDrag
        initialPosition = objectToDrag.position
    }
}
