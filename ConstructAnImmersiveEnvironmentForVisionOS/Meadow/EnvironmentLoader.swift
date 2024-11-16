/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Loads the immersive environment.
*/

import RealityKit
import RealityKitContent

// Cache to avoid loading the environment twice, when
// switching between the window and the ImmersiveSpace
actor EnvironmentLoader {

    // Weak reference to the loaded environment
    private weak var entity: Entity?

    // Returning the cached Entity or loading it otherwise
    func getEntity() async throws -> Entity {
        if let entity = entity { return entity }
        let entity = try await Entity(named: "Garden", in: realityKitContentBundle)
        self.entity = entity
        return entity
    }
}
