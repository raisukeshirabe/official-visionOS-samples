/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app’s overall state.
*/

import Foundation
import ARKit
import RealityKit

@Observable
class AppState {
    var immersiveSpaceOpened: Bool { placementManager != nil }
    private(set) weak var placementManager: PlacementManager? = nil

    private(set) var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    private(set) var modelDescriptors: [ModelDescriptor] = []
    var selectedFileName: String?

    func immersiveSpaceOpened(with manager: PlacementManager) {
        placementManager = manager
    }

    func didLeaveImmersiveSpace() {
        // Remember which placed object is attached to which persistent world anchor when leaving the immersive space.
        if let placementManager {
            placementManager.saveWorldAnchorsObjectsMapToDisk()
            
            // Stop the providers. The providers that just ran in the
            // immersive space are paused now, but the session doesn’t need them anymore.
            // When the user reenters the immersive space, the app runs a new set of providers.
            arkitSession.stop()
        }
        placementManager = nil
    }

    func setPlaceableObjects(_ objects: [PlaceableObject]) {
        placeableObjectsByFileName = objects.reduce(into: [:]) { map, placeableObject in
            map[placeableObject.descriptor.fileName] = placeableObject
        }

        // Sort descriptors alphabetically.
        modelDescriptors = objects.map { $0.descriptor }.sorted { lhs, rhs in
            lhs.displayName < rhs.displayName
        }
   }

    // MARK: - ARKit state

    var arkitSession = ARKitSession()
    var providersStoppedWithError = false
    var worldSensingAuthorizationStatus = ARKitSession.AuthorizationStatus.notDetermined
    
    var allRequiredAuthorizationsAreGranted: Bool {
        worldSensingAuthorizationStatus == .allowed
    }

    var allRequiredProvidersAreSupported: Bool {
        WorldTrackingProvider.isSupported && PlaneDetectionProvider.isSupported
    }

    var canEnterImmersiveSpace: Bool {
        allRequiredAuthorizationsAreGranted && allRequiredProvidersAreSupported
    }

    func requestWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.requestAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }
    
    func queryWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.queryAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }

    func monitorSessionEvents() async {
        for await event in arkitSession.events {
            switch event {
            case .dataProviderStateChanged(_, let newState, let error):
                switch newState {
                case .initialized:
                    break
                case .running:
                    break
                case .paused:
                    break
                case .stopped:
                    if let error {
                        print("An error occurred: \(error)")
                        providersStoppedWithError = true
                    }
                @unknown default:
                    break
                }
            case .authorizationChanged(let type, let status):
                print("Authorization type \(type) changed to \(status)")
                if type == .worldSensing {
                    worldSensingAuthorizationStatus = status
                }
            default:
                print("An unknown event occured \(event)")
            }
        }
    }

    // MARK: - Xcode Previews

    fileprivate var previewPlacementManager: PlacementManager? = nil

    /// An initial app state for previews in Xcode.
    @MainActor
    static func previewAppState(immersiveSpaceOpened: Bool = false, selectedIndex: Int? = nil) -> AppState {
        let state = AppState()

        state.setPlaceableObjects([previewObject(named: "White sphere"),
                                   previewObject(named: "Red cube"),
                                   previewObject(named: "Blue cylinder")])

        if let selectedIndex, selectedIndex < state.modelDescriptors.count {
            state.selectedFileName = state.modelDescriptors[selectedIndex].fileName
        }

        if immersiveSpaceOpened {
            state.previewPlacementManager = PlacementManager()
            state.placementManager = state.previewPlacementManager
        }

        return state
    }
    
    @MainActor
    private static func previewObject(named fileName: String) -> PlaceableObject {
        return PlaceableObject(descriptor: ModelDescriptor(fileName: fileName),
                               renderContent: ModelEntity(),
                               previewEntity: ModelEntity())
    }
}
