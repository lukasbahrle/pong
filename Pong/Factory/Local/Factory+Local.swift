//
//  GameViewModelFactory+Local.swift
//  Pong
//
//  Created by Bahrle, Lukas on 20/1/23.
//

import Foundation

extension Factory {
    @MainActor static func local() -> GameViewModel {
        let controller = LocalGameController()
        
        let logic = GameLogic(stateController: Self.stateController())
        
        return GameViewModel(gameInput: logic, gameOutput: logic, gameController: controller)
    }
}
