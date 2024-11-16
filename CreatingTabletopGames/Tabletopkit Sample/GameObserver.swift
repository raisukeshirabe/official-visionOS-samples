/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Respond to asynchronous callbacks throughout gameplay.
*/
import TabletopKit
import RealityKit

class GameObserver: TabletopGame.Observer {
    let tabletop: TabletopGame
    let renderer: GameRenderer

    init(tabletop: TabletopGame, renderer: GameRenderer) {
        self.tabletop = tabletop
        self.renderer = renderer
    }

    func actionIsPending(_ action: some TabletopAction, oldSnapshot: TableSnapshot, newSnapshot: TableSnapshot) {
        if let action = action as? MoveEquipmentAction {
            if let (die, _) = newSnapshot.equipment(of: Die.self, matching: action.equipmentID) {
                Task { @MainActor in
                    die.playTossSound()
                }
                return
            }
        }

        if let action = action as? UpdateCounterAction {
            if let (card, _) = newSnapshot.equipment(of: Card.self, matching: .init(Int(action.newValue))) {
                Task { @MainActor in
                    card.playPickupSound()
                }
                return
            }
        }
    }

    func actionWasConfirmed(_ action: some TabletopAction, oldSnapshot: TableSnapshot, newSnapshot: TableSnapshot) {
        guard let action = action as? MoveEquipmentAction,
              let destination = newSnapshot.equipment(of: ConveyorTile.self, matching: action.parentID),
              let pawn = newSnapshot.equipment(of: PlayerPawn.self, matching: action.equipmentID) else {
            return
        }

        let category = destination.0.category
        let color = pawn.0.cuteBotColor
        let renderer = self.renderer
        Task { @MainActor in
            renderer.playAnimationForTile(category: category, cuteBotColor: color)
        }
    }
    
    func playerChangedSeats(_ player: Player, oldSeat: (any TableSeat)?, newSeat: (any TableSeat)?, snapshot: TableSnapshot) {
        if player.id == tabletop.localPlayer.id, newSeat == nil {
            tabletop.claimAnySeat()
        }
    }
}
