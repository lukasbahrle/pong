//
//  GameViewModelFactory.swift
//  Pong
//
//  Created by Bahrle, Lukas on 20/1/23.
//

import Foundation

enum Factory {
    static func stateController() -> GameStateController {
        GameStateController(score: .initialScore, target: 3)
    }
}
