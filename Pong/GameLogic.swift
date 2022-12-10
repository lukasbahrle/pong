//
//  GameLogic.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation
import Combine

struct GameScore {
    var player: Int
    var opponent: Int

    static let initialScore = GameScore(player: 0, opponent: 0)
    
    func isGameOver(target: Int) -> Bool {
        max(player, opponent) >= target
    }
}

class GameLogic {
    private(set) var score: GameScore {
        didSet {
            onScoreUpdate(score, score.isGameOver(target: targetScore))
        }
    }
    
    let targetScore: Int
    let onScoreUpdate: (_ score: GameScore, _ isGameOver: Bool) -> Void
    
    internal init(score: GameScore = GameScore.initialScore, targetScore: Int, onScoreUpdate: @escaping (_ score: GameScore, _ isGameOver: Bool) -> Void) {
        self.score = score
        self.targetScore = targetScore
        self.onScoreUpdate = onScoreUpdate
    }
    
    func start() {}
    func movePlayer(x: CGFloat) {}
    func moveOpponent(x: CGFloat) {}
    func update(timestamp: TimeInterval, screenRatio: CGFloat) {}
}
