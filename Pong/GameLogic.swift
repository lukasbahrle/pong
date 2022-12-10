//
//  GameLogic.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation
import Combine

class GameLogic {
    private(set) var score: GameScore {
        didSet {
            onScoreUpdate(score, score.isGameOver(target: targetScore))
        }
    }
    
    // MARK: - Game objects
    
    let ball: GameObject = .ball
    let player: GameObject = .paddle(true)
    let opponent: GameObject = .paddle(false)
    
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
