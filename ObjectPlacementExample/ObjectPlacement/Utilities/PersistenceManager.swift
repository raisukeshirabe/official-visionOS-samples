/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class which is responsible for mapping persistent world anchors to placed objects.
*/

import Foundation
import ARKit
import RealityKit

class PersistenceManager {
    private var worldTracking: WorldTrackingProvider
    
    // A map of world anchor UUIDs to the objects attached to them.
    private var anchoredObjects: [UUID: PlacedObject] = [:]
    
    // A map of world anchor UUIDs to the objects that are about to be attached to them.
    private var objectsBeingAnchored: [UUID: PlacedObject] = [:]
    
    // A list of objects that are currently not at rest (not attached to any world anchor).
    private var movingObjects: [PlacedObject] = []
    
    private let objectAtRestThreshold: Float = 0.001 // 1 cm
    
    // A dictionary of all current world anchors based on the anchor updates received from ARKit.
    private var worldAnchors: [UUID: WorldAnchor] = [:]
    
    // The JSON file to store the world anchor to placed object mapping.
    static let objectsDatabaseFileName = "persistentObjects.json"
    
    // A dictionary of 3D model files to be loaded for a given persistent world anchor.
    private var persistedObjectFileNamePerAnchor: [UUID: String] = [:]
    
    var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    
    private var rootEntity: Entity
    
    init(worldTracking: WorldTrackingProvider, rootEntity: Entity) {
        self.worldTracking = worldTracking
        self.rootEntity = rootEntity
    }
    
    /// Deserialize the JSON file that contains the mapping from world anchors to placed objects from the documents directory.
    func loadPersistedObjects() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = documentsDirectory.first?.appendingPathComponent(PersistenceManager.objectsDatabaseFileName)
        
        guard let filePath, FileManager.default.fileExists(atPath: filePath.path(percentEncoded: true)) else {
            print("Couldn’t find file: '\(PersistenceManager.objectsDatabaseFileName)' - skipping deserialization of persistent objects.")
            return
        }

        do {
            let data = try Data(contentsOf: filePath)
            persistedObjectFileNamePerAnchor = try JSONDecoder().decode([UUID: String].self, from: data)
        } catch {
            print("Failed to restore the mapping from world anchors to persisted objects.")
        }
    }
    
    /// Serialize the mapping from world anchors to placed objects to a JSON file in the documents directory.
    func saveWorldAnchorsObjectsMapToDisk() {
        var worldAnchorsToFileNames: [UUID: String] = [:]
        for (anchorID, object) in anchoredObjects {
            worldAnchorsToFileNames[anchorID] = object.fileName
        }
        
        let encoder = JSONEncoder()
        do {
            let jsonString = try encoder.encode(worldAnchorsToFileNames)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsDirectory.appendingPathComponent(PersistenceManager.objectsDatabaseFileName)

            do {
                try jsonString.write(to: filePath)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }

    @MainActor
    func attachPersistedObjectToAnchor(_ modelFileName: String, anchor: WorldAnchor) {
        guard let placeableObject = placeableObjectsByFileName[modelFileName] else {
            print("No object available for '\(modelFileName)' - it will be ignored.")
            return
        }

        let object = placeableObject.materialize()
        object.position = anchor.originFromAnchorTransform.translation
        object.orientation = anchor.originFromAnchorTransform.rotation
        object.isEnabled = anchor.isTracked
        rootEntity.addChild(object)

        anchoredObjects[anchor.id] = object
    }
    
    @MainActor
    func process(_ anchorUpdate: AnchorUpdate<WorldAnchor>) {
        let anchor = anchorUpdate.anchor
        
        if anchorUpdate.event != .removed {
            worldAnchors[anchor.id] = anchor
        } else {
            worldAnchors.removeValue(forKey: anchor.id)
        }
        
        switch anchorUpdate.event {
        case .added:
            // Check whether there’s a persisted object attached to this added anchor -
            // it could be a world anchor from a previous run of the app.
            // ARKit surfaces all of the world anchors associated with this app
            // when the world tracking provider starts.
            if let persistedObjectFileName = persistedObjectFileNamePerAnchor[anchor.id] {
                attachPersistedObjectToAnchor(persistedObjectFileName, anchor: anchor)
            } else if let objectBeingAnchored = objectsBeingAnchored[anchor.id] {
                objectsBeingAnchored.removeValue(forKey: anchor.id)
                anchoredObjects[anchor.id] = objectBeingAnchored
                
                // Now that the anchor has been successfully added, display the object.
                rootEntity.addChild(objectBeingAnchored)
            } else {
                if anchoredObjects[anchor.id] == nil {
                    Task {
                        // Immediately delete world anchors for which no placed object is known.
                        print("No object is attached to anchor \(anchor.id) - it can be deleted.")
                        await removeAnchorWithID(anchor.id)
                    }
                }
            }
            fallthrough
        case .updated:
            // Keep the position of placed objects in sync with their corresponding
            // world anchor, and hide the object if the anchor isn’t tracked.
            let object = anchoredObjects[anchor.id]
            object?.position = anchor.originFromAnchorTransform.translation
            object?.orientation = anchor.originFromAnchorTransform.rotation
            object?.isEnabled = anchor.isTracked
        case .removed:
            // Remove the placed object if the corresponding world anchor was removed.
            let object = anchoredObjects[anchor.id]
            object?.removeFromParent()
            anchoredObjects.removeValue(forKey: anchor.id)
        }
    }
    
    @MainActor
    func removeAllPlacedObjects() async {
        // To delete all placed objects, first delete all their world anchors.
        // The placed objects will then be removed after the world anchors
        // were successfully deleted.
        await deleteWorldAnchorsForAnchoredObjects()
    }
    
    private func deleteWorldAnchorsForAnchoredObjects() async {
        for anchorID in anchoredObjects.keys {
            await removeAnchorWithID(anchorID)
        }
    }
    
    func removeAnchorWithID(_ uuid: UUID) async {
        do {
            try await worldTracking.removeAnchor(forID: uuid)
        } catch {
            print("Failed to delete world anchor \(uuid) with error \(error).")
        }
    }
    
    @MainActor
    func attachObjectToWorldAnchor(_ object: PlacedObject) async {
        // First, create a new world anchor and try to add it to the world tracking provider.
        let anchor = WorldAnchor(originFromAnchorTransform: object.transformMatrix(relativeTo: nil))
        movingObjects.removeAll(where: { $0 === object })
        objectsBeingAnchored[anchor.id] = object
        do {
            try await worldTracking.addAnchor(anchor)
        } catch {
            // Adding world anchors can fail, such as when you reach the limit
            // for total world anchors per app. Keep track
            // of all world anchors and delete any that no longer have
            // an object attached.
            
            if let worldTrackingError = error as? WorldTrackingProvider.Error, worldTrackingError.code == .worldAnchorLimitReached {
                print(
"""
Unable to place object "\(object.name)". You’ve placed the maximum number of objects.
Remove old objects before placing new ones.
"""
                )
            } else {
                print("Failed to add world anchor \(anchor.id) with error: \(error).")
            }
            
            objectsBeingAnchored.removeValue(forKey: anchor.id)
            object.removeFromParent()
            return
        }
    }
    
    @MainActor
    private func detachObjectFromWorldAnchor(_ object: PlacedObject) {
        guard let anchorID = anchoredObjects.first(where: { $0.value === object })?.key else {
            return
        }
        
        // Remove the object from the set of anchored objects because it’s about to be moved.
        anchoredObjects.removeValue(forKey: anchorID)
        Task {
            // The world anchor is no longer needed; remove it so that it doesn't
            // remain in the app’s list of world anchors forever.
            await removeAnchorWithID(anchorID)
        }
    }
    
    @MainActor
    func placedObject(for entity: Entity) -> PlacedObject? {
        return anchoredObjects.first(where: { $0.value === entity })?.value
    }
    
    @MainActor
    func object(for entity: Entity) -> PlacedObject? {
        if let placedObject = placedObject(for: entity) {
            return placedObject
        }
        if let movingObject = movingObjects.first(where: { $0 === entity }) {
            return movingObject
        }
        if let anchoringObject = objectsBeingAnchored.first(where: { $0.value === entity })?.value {
            return anchoringObject
        }
        return nil
    }
    
    @MainActor
    func removeObject(_ object: PlacedObject) async {
        guard let anchorID = anchoredObjects.first(where: { $0.value === object })?.key else {
            return
        }
        await removeAnchorWithID(anchorID)
    }
    
    @MainActor
    func checkIfAnchoredObjectsNeedToBeDetached() async {
        let anchoredObjectsBeforeCheck = anchoredObjects
        
        // Check if any of the anchored objects is no longer at rest
        // and needs to be detached from its world anchor.
        for (anchorID, object) in anchoredObjectsBeforeCheck {
            guard let anchor = worldAnchors[anchorID] else {
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                movingObjects.append(object)
                anchoredObjects.removeValue(forKey: anchorID)
                continue
            }
            
            let distanceToAnchor = object.position(relativeTo: nil) - anchor.originFromAnchorTransform.translation
            
            if length(distanceToAnchor) >= objectAtRestThreshold {
                object.atRest = false
                
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                movingObjects.append(object)
                detachObjectFromWorldAnchor(object)
            }
        }
    }
    
    @MainActor
    func checkIfMovingObjectsCanBeAnchored() async {
        let movingObjectsBeforeCheck = movingObjects
        
        // Check whether any of the nonanchored objects are now at rest
        // and can be attached to a new world anchor.
        for object in movingObjectsBeforeCheck {
            guard !object.isBeingDragged else { continue }
            guard let lastPosition = object.positionAtLastReanchoringCheck else {
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                continue
            }
            
            let currentPosition = object.position(relativeTo: nil)
            let movementSinceLastCheck = currentPosition - lastPosition
            object.positionAtLastReanchoringCheck = currentPosition
            
            if length(movementSinceLastCheck) < objectAtRestThreshold {
                object.atRest = true
                await attachObjectToWorldAnchor(object)
            }
        }
    }
}
