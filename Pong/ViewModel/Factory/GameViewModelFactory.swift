//
//  GameViewModelFactory.swift
//  Pong
//
//  Created by Bahrle, Lukas on 20/1/23.
//

import Foundation

enum GameViewModelFactory {
    @MainActor static func make(_ groupActivity: PongGroupActivity = LivePongGroupActivity()) -> GameViewModel {
        let stateController = GameStateController(score: .initialScore, target: 3)
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
