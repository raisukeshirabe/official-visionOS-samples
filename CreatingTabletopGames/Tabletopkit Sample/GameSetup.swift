/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Setup of the table for the game.
*/

import TabletopKit
import RealityKit
import SwiftUI
import TabletopGameSampleContent
import Spatial

enum GameMetrics {
    static let tableEdge: Float = 0.7
    static let tableThickness: Float = 0.0146
    static let playerAreaDistanceFromCenter: Float = 0.29
    static let boardEdge: Float = 0.4
    static let smallHeight: Float = 0.001
    static let boardHeight: Float = 0.055
    static let playerAreaSize: SIMD2<Float> = SIMD2(0.4, 0.1)
    static let playerHandSize: SIMD2<Float> = SIMD2(0.2, 0.1)
}

@MainActor
class GameSetup {
    let root: Entity
    var setup: TableSetup
    let board: Board
    var cardStockGroup: CardStockGroup
    let counter: ScoreCounter
    var pawns: [PlayerPawn] = []
    var cards: [Card] = []
    var seats: [PlayerSeat] = []

    // This is an incrementing counter to generate unique IDs for each piece of equipment.
    struct IdentifierGenerator {
        private var count = 0

        mutating func newId() -> Int {
            count += 1
            return count
        }
    }
    var idGenerator = IdentifierGenerator()

    /*
     The table has a board in the center,
     with a hand and a pawn for each player around the sides.
     The side without a seat has the deck and the die.
     
            +---+
            |die|   +------+
            +---+   | deck |
                    +------+
       pawn
       +-+     +---+-+-+-+-+-+-+---+
       +-+     |   | | | | | | |   |
               +---+-+-+-+-+-+-+---+  +-----+
     +-----+   |---|           |---|  |     |
     |     |   |---|           |---|  |hand |
     |hand |   |---|  board    |---|  |     |
     |     |   |---|           |---|  |     |
     |     |   |---|           |---|  |     |
     |     |   +---+-+-+-+-+-+-+---+  +-----+
     +-----+   |   | | | | | | |   |
               +---+-+-+-+-+-+-+---+    +-+
                                        +-+
           +-+   +-----------+          pawn
           +-+   |           |
           pawn  |   hand    |
                 +-----------+
     */
    init(root: Entity) {
        self.root = root
        setup = TableSetup(tabletop: Table())

        for (index, pose) in PlayerSeat.seatPoses.enumerated() {
            let seat = PlayerSeat(id: TableSeatIdentifier(index), pose: pose)
            seats.append(seat)
            setup.add(seat: seat)
        }

        board = Board(id: EquipmentIdentifier(self.idGenerator.newId()))
        setup.add(equipment: board)

        cardStockGroup = CardStockGroup(id: EquipmentIdentifier(self.idGenerator.newId()))
        setup.add(equipment: cardStockGroup)

        counter = ScoreCounter(id: .init(self.idGenerator.newId()))
        setup.add(counter: counter)

        let die = Die(id: EquipmentIdentifier(self.idGenerator.newId()))
        setup.add(equipment: die)
        
        loadRoadGroups()
        
        loadPlayerCardGroups()
        
        loadEntityEquipment()
    }
    
    func loadRoadGroups() {
        for tileConfig in ConveyorTile.tiles {
            // Transform from a pose on a unit square to an absolute pose in the table's coordinate space.
            let positionX = (tileConfig.0.x - 0.5) * ConveyorTile.positionScale
            let positionY = (tileConfig.0.z - 0.5) * ConveyorTile.positionScale
            let tile = ConveyorTile(id: EquipmentIdentifier(self.idGenerator.newId()),
                                    boardID: board.id,
                                    position: .init(x: positionX, z: positionY),
                                    category: tileConfig.1)
            setup.add(equipment: tile)
        }
    }
    
    func loadPlayerCardGroups() {
        for seat in self.seats {
            let group = CardGroup(id: EquipmentIdentifier(self.idGenerator.newId()), seat: seat, root: root)
            setup.add(equipment: group)
        }
    }
    
    func loadEntityEquipment() {
        for (index, pawnInfo) in PlayerPawn.pawns.enumerated() {
            let pawn = PlayerPawn(id: PlayerPawn.ID(self.idGenerator.newId()),
                                  seat: seats[index],
                                  cuteBotColor: pawnInfo.1,
                                  entity: try! Entity.load(named: pawnInfo.0, in: tabletopGameSampleContentBundle))
            pawns.append(pawn)
            setup.add(equipment: pawn)
        }
        
        let cardEntities = [
            (try! ModelEntity.load(named: "card_arm_01_assembly", in: tabletopGameSampleContentBundle), Card.Classification.arm),
            (try! ModelEntity.load(named: "card_flower_01_assembly", in: tabletopGameSampleContentBundle), Card.Classification.flower),
            (try! ModelEntity.load(named: "card_leg_01_assembly", in: tabletopGameSampleContentBundle), Card.Classification.leg)
        ]

        let audioResource = try! AudioFileResource.load(named: "/Root/pickUpCard_mp3",
                                                        from: "static_scene.usda",
                                                        in: tabletopGameSampleContentBundle)
        for _ in 0 ..< 5 {
            for cardEntity in cardEntities {
                let card = Card(id: EquipmentIdentifier(self.idGenerator.newId()),
                                classification: cardEntity.1,
                                parent: cardStockGroup.id,
                                entity: cardEntity.0.clone(recursive: true),
                                audioResource: audioResource)
                cards.append(card)
                setup.add(equipment: card)
            }
        }
    }
}

extension Game {
    @MainActor
    func resetGame() {
        // Move pawns back to their starting location.
        for pawn in setup.pawns {
            tabletopGame.addAction(.moveEquipment(matching: pawn.id, childOf: .tableID, pose: pawn.initialState.pose))
        }

        // Shuffle cards and return them to the stockpile, face down, controlled by any seat.
        let cardsShuffled = setup.cards.shuffled()
        for card in cardsShuffled {
            tabletopGame.addAction(.updateEquipment(card, faceUp: false, seatControl: .any))
            tabletopGame.addAction(.moveEquipment(matching: card.id, childOf: setup.cardStockGroup.id))
        }
    }
}
