//
//  GameLogic.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation
import Combine

class GameLogic {
    private(set) var gameState: GameState = .readyToPlay {
        didSet {
            onScoreUpdate(score, score.isGameOver(target: targetScore))
        }
    }
    let onGameStateUpdate: (_ state: GameState) -> Void
    
    private(set) var score: GameScore {
        didSet {
            onScoreUpdate(score, score.isGameOver(target: targetScore))
        }
    }
    let targetScore: Int
    let onScoreUpdate: (_ score: GameScore, _ isGameOver: Bool) -> Void
    
    // MARK: - Game objects
    
    let ball: GameObject = .ball
    let player: GameObject = .paddle(true)
    let opponent: GameObject = .paddle(false)
    
    private var lastUpdate: TimeInterval = -1
    
    internal init(score: GameScore = GameScore.initialScore, targetScore: Int, onScoreUpdate: @escaping (_ score: GameScore, _ isGameOver: Bool) -> Void, onGameStateUpdate: @escaping (_ gameState: GameState) -> Void) {
        self.score = score
        self.targetScore = targetScore
        self.onScoreUpdate = onScoreUpdate
        self.onGameStateUpdate = onGameStateUpdate
    }
    
    func start() {}
    
    func movePlayer(x: CGFloat) {
        movePaddle(player, x: x)
    }
    func moveOpponent(x: CGFloat) {
        movePaddle(opponent, x: x)
    }
    
    private func movePaddle(_ paddle: GameObject, x: CGFloat) {
        paddle.position.x = min(max(0, x - paddle.width * 0.5), 1 - paddle.width)
    }
    
    func update(timestamp: TimeInterval, screenRatio: CGFloat) {
        guard lastUpdate > 0 else {
            lastUpdate = timestamp
            return
        }
        
        let deltaTime = timestamp - lastUpdate
        lastUpdate = timestamp
        
        ball.update(deltaTime: deltaTime)
        player.update(deltaTime: deltaTime, move: false)
        opponent.update(deltaTime: deltaTime, move: false)
    }
}
