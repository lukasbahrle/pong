//
//  GameViewModelFactory.swift
//  Pong
//
//  Created by Bahrle, Lukas on 20/1/23.
//

import Foundation

extension Factory {
    @MainActor static func groupActivity(_ groupActivity: PongGroupActivity = LivePongGroupActivity()) -> GameViewModel {
        let stateController = Self.stateController()
        let disableableStateController = DisableableGameStateController(gameStateController: stateController)
        let logic = GameLogic(stateController: disableableStateController)
        
        let activityController = PongActivityController(groupActivity: groupActivity, gameInput: logic, gameOutput: logic) { isEnabled in
            disableableStateController.isEnabled = isEnabled
        } updateStateController: { state, score in
            stateController.update(state, score: score)
        }
        
        return GameViewModel(gameInput: activityController, gameOutput: activityController, gameController: activityController)
    }
}
