/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object to respond to player interactions and update gameplay.
*/
import TabletopKit
import RealityKit

struct GameInteraction: TabletopInteraction.Delegate {
    let game: Game
    
    @MainActor
    func updateCursor(_ proposedDestination: EquipmentIdentifier?, valid: Bool = false) {
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

    mutating func update(interaction: TabletopKit.TabletopInteraction) {
        var destination = interaction.value.proposedDestination?.equipmentID
        
        if interaction.value.phase == .started {
            onPhaseStarted(interaction: interaction)
        }
        
        if interaction.value.gesturePhase == .ended {
            onGesturePhaseEnded(interaction: interaction)
        }

        if interaction.value.phase == .ended {
            destination = nil
            onPhaseEnded(interaction: interaction)
        }
        
        game.renderer.updateCursor(destination)
    }
    
    func onPhaseStarted(interaction: TabletopInteraction) {
        if game.tabletopGame.equipment(of: PlayerPawn.self, matching: interaction.value.startingEquipmentID) != nil {
            // Only allow pawns to move to conveyor tiles.
            interaction.setAllowedDestinations(.restricted(game.tabletopGame.equipment(of: ConveyorTile.self).map(\.id)))
        }

        if let card = game.tabletopGame.equipment(of: Card.self, matching: interaction.value.startingEquipmentID) {
            // Only allow cards to move to the local player's hand or the deck.
            var allowedDestinations = game.tabletopGame.equipment(of: CardStockGroup.self).map(\.id)
            game.tabletopGame.withCurrentSnapshot { snapshot in
                guard let localSeat = snapshot.seat(of: PlayerSeat.self, for: game.tabletopGame.localPlayer) else {
                    return
                }
                let cardGroups = game.tabletopGame.equipment(of: CardGroup.self)
                for group in cardGroups where group.owner.id == localSeat.0.id {
                    allowedDestinations.append(group.id)
                }
                
                interaction.setAllowedDestinations(.restricted(allowedDestinations))
            }
            // Use counter action to signal to all players that someone picked up the card.
            interaction.addAction(.updateCounter(matching: game.setup.counter.id, value: Int64(card.id.rawValue)))
        }

        if game.tabletopGame.equipment(of: Die.self, matching: interaction.value.startingEquipmentID) != nil {
            // Don't let the die land on any other equipment, just the table.
            interaction.setAllowedDestinations(.restricted([]))
        }
    }
    
    func onGesturePhaseEnded(interaction: TabletopInteraction) {
        if let die = game.tabletopGame.equipment(of: Die.self, matching: interaction.value.startingEquipmentID) {
            // Play a sound when a player tosses a die.
            Task { @MainActor in
                if let audioLibraryComponent = die.entity.components[AudioLibraryComponent.self] {
                    if let soundResource = audioLibraryComponent.resources["dieSoundShort.mp3"] {
                        die.entity.playAudio(soundResource)
                    }
                }
            }
            // Pick a random value for the result of the die toss and toss the die.
            let nextValue = Int.random(in: 1 ... 6)
            interaction.addAction(.updateEquipment(die, state: .init(value: nextValue, parentID: .tableID, entity: die.entity)))
            interaction.toss(equipmentID: interaction.value.startingEquipmentID, as: die.representation)
            // Move the die back to the starting pose on the table after toss animation finishes.
            interaction.addAction(.moveEquipment(matching: die.id, childOf: .tableID, pose: die.initialState.pose))
        }
    }
    
    func onPhaseEnded(interaction: TabletopInteraction) {
        /* If there isn't a proposed destination, there's nothing to do here.
         Objects moving back to their original group animate there smoothly by default. */
        guard let dst = interaction.value.proposedDestination else {
            return
        }
        
        if let pawn = game.tabletopGame.equipment(of: PlayerPawn.self, matching: interaction.value.startingEquipmentID) {
            // Move the pawn to its new proposed destination with a default pose (centered in new destination).
            interaction.addAction(.moveEquipment(matching: pawn.id, childOf: dst.equipmentID, pose: .init()))
        }
        
        if let card = game.tabletopGame.equipment(of: Card.self, matching: interaction.value.startingEquipmentID) {
            // If the card moves to the deck, make sure it's face down, and allow any player to pick it up.
            var seatControl: ControllingSeats = .any
            var faceUp = false
            // If the card moves to a player's hand, make sure it's face up, and only allow that player to interact with it.
            if let dstGroup = game.tabletopGame.equipment(of: CardGroup.self, matching: dst.equipmentID) {
                seatControl = .restricted([dstGroup.owner.id])
                faceUp = true
            }
            interaction.addAction(.updateEquipment(card, faceUp: faceUp, seatControl: seatControl))
            interaction.addAction(.moveEquipment(matching: card.id, childOf: dst.equipmentID))
        }
    }
}
