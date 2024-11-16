/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A state machine that tracks the robot's animations.
*/

import Foundation
import RealityKit

typealias AnimationStateMachineHandler = (AnimationState) -> Void

/// An enumeration that represents a state machine that tracks the current animation state of the robot.
public enum AnimationState: String, Codable, Sendable, Equatable, CaseIterable {
    case idle
    case walkLoop
    case walkEnd
    case plant
    case celebrate
    case wave
    
    public enum AnimationLoopingBehavior {
        case infinite
        case finite (times: Int)
    }
    
    @MainActor static var handlers = [AnimationStateMachineHandler]()
    
    /// Returns an array containing all valid state transitions from the current state.
    var validNextStates: [AnimationState] {
        switch self {
            case .idle:
                return [.walkLoop, .plant, .celebrate, .wave]
            case .walkLoop:
                return [.walkEnd, .celebrate]
            case .walkEnd, .plant:
                return [.idle, .celebrate, .wave, .walkLoop]
            case .celebrate, .wave:
                return [.idle]
        }
    }
    
    @MainActor
    func registerHandler(_ handler: @escaping AnimationStateMachineHandler) {
        AnimationState.handlers.append(handler)
        // Call the handler for the current state, since it doesn't exist during the transition.
        handler(self)
    }
   
    /// The looping behavior of the animation state.
    var loopingBehavior: AnimationLoopingBehavior {
        if [.idle, .walkLoop, .celebrate].contains(self) {
            return .infinite
        } else {
            return .finite(times: 1)
        }
    }
    
    var nextState: AnimationState {
        switch self {
        case .walkEnd, .celebrate, .plant, .wave:
                return .idle
            default:
                return self
        }
    }
    
    func fileSuffix() -> String {
        return "_\(self.rawValue)_anim"
    }
    
    @MainActor
    mutating func reset() {
        self = .idle
        for handler in AnimationState.handlers {
            handler(self)
        }
    }
    
    func isValidNextState(_ state: AnimationState) -> Bool {
        return validNextStates.contains(state)
    }
    
    /// Requests a state transition.
    @MainActor
    @discardableResult
    mutating public func transition(to newState: AnimationState) -> Bool {
        let oldValue = self.rawValue
        logger.info("Attempting to change state from \(oldValue) to \(newState.rawValue)")
        guard self != newState else {
            logger.debug("Attempting to change phase to \(newState.rawValue) but already in that state. Treating as a no-op.")
            return false
        }
        guard isValidNextState(newState) else {
            logger.error("Requested transition from \(oldValue) to \(newState.rawValue), but that's not a valid transition.")
            return false
        }
        self = newState
        for handler in AnimationState.handlers {
            handler(self)
        }
        return true
    }
}
