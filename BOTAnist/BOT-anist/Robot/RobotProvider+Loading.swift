/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Loads and provides access to robot parts and materials.
*/

import Foundation
@preconcurrency import RealityKit
import BOTanistAssets

extension RobotProvider {
    
    /// Loads a named entity from a specific scene in the Reality Composer Pro project.
    func loadEntityFromRCPro(named entityName: String,
                             fromSceneNamed sceneName: String) async throws -> Entity? {
        var ret: Entity? = nil
        logger.info("Loading entity \(entityName) from Reality Composer Pro scene \(sceneName)")
        do {
            let scene = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
            ret = scene.findEntity(named: entityName)
        } catch {
            fatalError("\tEncountered fatal error: \(error.localizedDescription)")
        }
        return ret
    }
    
    /// Loads materials of a specific type from the Reality Composer Pro project.
    ///
    /// This method assumes that each material is a child of an entity with the same name and that the material is bound to that entity.
    func loadMaterialsFromRCPro(material: RobotMaterial) async throws -> [RobotPart: [ShaderGraphMaterial]] {
        var materials = [RobotPart: [ShaderGraphMaterial]]()
        logger.info("Loading materials from Reality Composer Pro scene for type \(material.rawValue)")
        do {
            let scene = try await Entity(named: material.sceneName, in: BOTanistAssetsBundle)
            for entityName in material.entityNames {
                guard let entity = scene.findEntity(named: entityName) else { fatalError("Missing expected material entity \(entityName)") }
                let components = entity.components
                guard let modelComponent = components[ModelComponent.self] else { fatalError("Model entity is required.") }
                guard let material = modelComponent.materials.first as? ShaderGraphMaterial else {
                    fatalError("Expected ShaderGraphMaterial not found.")
                }
                guard let name = material.name else { fatalError("Robot materials must have name. No name found.") }
                if let part = RobotPart.partForMaterialName(name: name) {
                    if materials[part] == nil {
                        materials[part] = [ShaderGraphMaterial]()
                    }
                    materials[part]?.append(material)
                }
            }
        } catch {
            fatalError("\tEncountered fatal error: \(error.localizedDescription)")
        }
        return materials
    }
    
    /// Loads each robot part asynchronously as a task that this method adds to a provided task group.
    func loadRobotParts(taskGroup: inout TaskGroup<RobotPartLoadResult>) async {
        RobotPart.allCases.forEach { part in
            for (index, sceneName) in part.sceneNames.enumerated() {
                taskGroup.addTask {
                    do {
                        let partName = part.partNames[index]
                        logger.info("Loading scene \(sceneName), part: \(partName) for part type \(part.rawValue)")
                        if let entity = try await self.loadEntityFromRCPro(named: partName, fromSceneNamed: sceneName) {
                            if part == .body {
                                var libComponent = AnimationLibraryComponent()
                                let animationDirectory = "Assets/Robot/animations/\(partName)/"
                                for animationType in AnimationState.allCases {
                                    if let rootEntity = try? await Entity(named: "\(animationDirectory)\(partName)\(animationType.fileSuffix())",
                                                                          in: BOTanistAssetsBundle) {
                                        if let animationEntity = await rootEntity.findEntity(named: "rig_grp") {
                                            if let animationLibraryComponent = await animationEntity.animationLibraryComponent {
                                                libComponent.animations[animationType.rawValue] = animationLibraryComponent.defaultAnimation
                                            }
                                        }
                                    }
                                }
                                await entity.components.set(libComponent)
                            }
                            return RobotPartLoadResult(entity: entity, type: part, index: index)
                        } else {
                            fatalError("Error loading robot part \(partName) from scene \(sceneName)")
                        }
                    } catch {
                        fatalError("Error loading scene \(sceneName) for part \(part.rawValue)")
                    }
                }
            }
        }
    }
    
    /// Loads each robot material asynchronously as a task that this method adds to a provided task group.
    func loadRobotMaterials(taskGroup: inout TaskGroup<RobotMaterialResult>) async {
        let materials = RobotMaterial.allCases
        for material in materials {
            taskGroup.addTask {
                do {
                    let theMaterials = try await self.loadMaterialsFromRCPro(material: material)
                    return RobotMaterialResult(material: material, materials: theMaterials)
                } catch {
                    fatalError("Error loading scene \(material.sceneName)")
                }
            }
        }
    }
}
