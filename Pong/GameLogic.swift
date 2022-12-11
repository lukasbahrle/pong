//
//  GameLogic.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation
import Combine

class GameLogic {
    enum State {
        case readyToPlay
        case playing
        case gameOver
    }
    
    private(set) var gameState: State = .readyToPlay {
        didSet {
            onGameStateUpdate(gameState)
        }
    }
    let onGameStateUpdate: (_ state: State) -> Void
    
    private(set) var score: GameScore {
        didSet {
            onScoreUpdate(score)
            if score.isGameOver(target: targetScore) {
                gameState = .gameOver
            }
        }
    }
    let targetScore: Int
    let onScoreUpdate: (GameScore) -> Void
    
    // MARK: - Game objects
    
    let ball: GameObject = .ball
    let player: GameObject = .paddle(true)
    let opponent: GameObject = .paddle(false)
    
    private var lastUpdate: TimeInterval = -1
    
    internal init(score: GameScore = GameScore.initialScore, targetScore: Int, onScoreUpdate: @escaping (GameScore) -> Void, onGameStateUpdate: @escaping (State) -> Void) {
        self.score = score
        self.targetScore = targetScore
        self.onScoreUpdate = onScoreUpdate
        self.onGameStateUpdate = onGameStateUpdate
    }
    
    func play() {
        ball.position = .init(x: 0.5, y: 0.5)
        ball.velocity = .init(x: 0, y: 0.2)
        gameState = .playing
    }
    
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
        
        guard gameState == .playing else { return }
        
        ball.update(deltaTime: deltaTime)
        player.update(deltaTime: deltaTime, move: false)
        opponent.update(deltaTime: deltaTime, move: false)
    }
}
