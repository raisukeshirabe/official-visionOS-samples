/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Render objects other than equipment.
*/
import TabletopKit
import RealityKit
import SwiftUI
import TabletopGameSampleContent

@MainActor
class GameRenderer: TabletopGame.RenderDelegate {
    let cursorEntity: Entity
    let root: Entity
    var cuteBots: [Entity] = []
    // The root offset controls the height of the table inside the app volume.
    let rootOffset: Vector3D = .init(x: 0, y: -0.7, z: 0)
    weak var game: Game?
    let portalWorld: Entity
    let portal: Entity
    
    @MainActor
    init() {
        // Move everything down within the volume so the tabletop is easier to see.
        root = Entity()
        root.transform.translation = .init(rootOffset)

        // Create a cursor mesh to show when a player hovers over a tile or group.
        self.cursorEntity = ModelEntity.cursor
        self.cursorEntity.setParent(root)
        
        portalWorld = Entity()
        portal = Entity()

        Task {
            await loadAssets()
        }
    }
    
    @MainActor
    func loadAssets() async {
        let staticSceneEntity = try! await Entity(named: "static_scene", in: tabletopGameSampleContentBundle)
        staticSceneEntity.setParent(root)

        let boardCavityEntity = try! await Entity(named: "board_cavity_assembly", in: tabletopGameSampleContentBundle)
        boardCavityEntity.transform.rotation = .init(angle: -.pi / 2, axis: .init(x: 0, y: 1, z: 0))

        // Set up portal to render the board internals without being clipped to the RealityView volume.
        // Both `portal` and `portalWorld` need to be added to the RealityView content.
        portalWorld.components.set(WorldComponent())
        portalWorld.addChild(boardCavityEntity)
        portalWorld.transform.translation = .init(rootOffset)
        portalWorld.transform.translation.y += GameMetrics.tableThickness * 0.5
        let portalMesh = MeshResource.generateBox(width: 0.6, height: 0, depth: 0.6)
        let portalEntity = ModelEntity(mesh: portalMesh, materials: [PortalMaterial()])
        let portalComp = PortalComponent(
            target: portalWorld,
            clippingPlane: .init(position: .init(), normal: .init(x: 0, y: -1, z: 0))
        )
        portalEntity.components.set(portalComp)
        portalEntity.transform.translation = .init(rootOffset)
        portal.addChild(portalEntity)
        
        await loadCuteBots()
    }

    @MainActor
    func loadCuteBots() async {
        // Load the smaller robots separately because they animate independently.
        let cuteBotTransforms: [(String, Transform)] = [
            ("cutebot_01", .init(translation: .init(x: -0.3, y: 0.019, z: 0.3)) ),
            ("cutebot_02", .init(rotation: .init(angle: (.pi / 2), axis: .init(x: 0, y: 1, z: 0)), translation: .init(x: 0.3, y: 0.019, z: 0.3))),
            ("cutebot_03", .init(rotation: .init(angle: (-.pi / 2), axis: .init(x: 0, y: 1, z: 0)), translation: .init(x: -0.3, y: 0.019, z: -0.3)))
        ]
        
        cuteBots = .init(repeating: Entity(), count: cuteBotTransforms.count)
        for index in 0...cuteBotTransforms.count - 1 {
            let bot = cuteBotTransforms[index]
            let botName = bot.0
            cuteBots[index] = try! await Entity(named: "\(botName)_assembly", in: tabletopGameSampleContentBundle)
            
            var libComponent = AnimationLibraryComponent()
            for animationState in PlayerPawn.AnimationState.allCases {
                let rootEntity = try! await Entity(named: "anim_\(animationState.rawValue)_\(botName)", in: tabletopGameSampleContentBundle)
                if let animationEntity = rootEntity.findEntity(named: "cutebot_bind") {
                    if let animation = animationEntity.availableAnimations.first {
                        libComponent.animations[animationState.rawValue] = animation
                    }
                } else {
                    fatalError("Didn't find animation entity for \(animationState.rawValue) for \(botName)")
                }
            }
            cuteBots[index].components.set(libComponent)
            // Start off with each robot doing the idle animation on loop until an interaction occurs.
            if let idle = getAnimation(entity: cuteBots[index], animation: .idleA) {
                playAnimation(entity: cuteBots[index], animation: idle.repeat())
            }
            
            cuteBots[index].transform = bot.1
            cuteBots[index].setParent(root)
        }
    }
    
    @MainActor
    var cursorTransform: Transform? = nil {
        willSet(newValue) {
            if cursorTransform == newValue {
                return
            }

            if cursorTransform == nil, let newValue {
                // When the cursor turns on, snap to the supplied position.
                cursorEntity.transform = newValue
                cursorEntity.isEnabled = true
            } else if let newValue {
                // Animate while the cursor is on.
                cursorEntity.move(to: newValue, relativeTo: root, duration: 0.1, timingFunction: .easeInOut)
            } else if newValue == nil {
                // Turn the cursor off.
                cursorEntity.isEnabled = false
            }
        }
    }

    @MainActor
    func getAnimation(entity: Entity, animation: PlayerPawn.AnimationState) -> AnimationResource? {
        if let component = entity.components[AnimationLibraryComponent.self] {
            return component.animations[animation.rawValue]
        }
        return nil
    }
    
    @MainActor
    func playAnimation(entity: Entity, animation: AnimationResource) {
        if let rigGroup = entity.findEntity(named: "cutebot_bind") {
            rigGroup.playAnimation(animation, transitionDuration: 1, startsPaused: false)
        }
    }
    
    @MainActor
    func playAnimationForTile(category: ConveyorTile.Category, cuteBotColor: PlayerPawn.CuteBotColor) {
        switch category {
            case .green:
                let cuteBotEntity = cuteBotEntity(for: cuteBotColor)
                if let celebrate = getAnimation(entity: cuteBotEntity, animation: .jumpJoy),
                   let idle = getAnimation(entity: cuteBotEntity, animation: .idleA) {
                    playAnimation(entity: cuteBotEntity, animation: try! .sequence(with: [celebrate, idle.repeat()]))
                }
            case .grey:
                // Just keep idling.
                break
            case .red:
                let cuteBotEntity = cuteBotEntity(for: cuteBotColor)
                if let sad = getAnimation(entity: cuteBotEntity, animation: .sad),
                   let idle = getAnimation(entity: cuteBotEntity, animation: .idleA) {
                    playAnimation(entity: cuteBotEntity, animation: try! .sequence(with: [sad, idle.repeat()]))
                }
        }
    }

    @MainActor
    func cuteBotEntity(for cuteBotColor: PlayerPawn.CuteBotColor) -> Entity {
        switch cuteBotColor {
        case .red:
            return cuteBots[0]
        case .blue:
            return cuteBots[1]
        case .purple:
            return cuteBots[2]
        }
    }
    
    nonisolated func updateCursor(_ proposedDestination: EquipmentIdentifier?, valid: Bool = false) {
        Task { @MainActor in
            guard let game = game else {
                return
            }
            if let proposedDestination, let tile = game.tabletopGame.equipment(of: ConveyorTile.self, matching: proposedDestination) {
                // Transform the tile position into table space and place the cursor there.
                let boardToTable = game.setup.board.initialState.pose
                let tileToBoard = tile.initialState.pose
                let tileToTable = tileToBoard * boardToTable
                game.renderer.cursorTransform = .init(translation: .init(x: Float(tileToTable.position.x),
                                                                         y: GameMetrics.boardHeight,
                                                                         z: Float(tileToTable.position.z)))
                
            } else {
                game.renderer.cursorTransform = nil
            }
        }
    }
}

extension ModelEntity {
    static var cursor: ModelEntity {
        let cursorMesh = MeshResource.generateCylinder(height: 0.01, radius: 0.02)
        let cursorEntity = ModelEntity(mesh: cursorMesh)
        cursorEntity.name = "cursor"
        cursorEntity.isEnabled = false
        var cursorMaterial = PhysicallyBasedMaterial()
        cursorMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .init(white: 0, alpha: 0.3))
        cursorMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1)
        cursorMaterial.blending = .transparent(opacity: 0.6)
        cursorEntity.model!.materials.append(cursorMaterial)
        return cursorEntity
    }
}
