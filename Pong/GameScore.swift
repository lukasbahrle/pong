//
//  GameScore.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation

struct GameScore {
    var player: Int
    var opponent: Int

    static let initialScore = GameScore(player: 0, opponent: 0)
    
    func isGameOver(target: Int) -> Bool {
        max(player, opponent) >= target
    }
}