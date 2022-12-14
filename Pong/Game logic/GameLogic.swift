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
    let wallLeft: GameObject = .wall(.left)
    let wallRight: GameObject = .wall(.right)
    let wallBottom: GameObject = .wall(.bottom)
    let wallTop: GameObject = .wall(.top)
    
    private var lastUpdate: TimeInterval = -1
    
    internal init(score: GameScore = GameScore.initialScore, targetScore: Int, onScoreUpdate: @escaping (GameScore) -> Void, onGameStateUpdate: @escaping (State) -> Void) {
        self.score = score
        self.targetScore = targetScore
        self.onScoreUpdate = onScoreUpdate
        self.onGameStateUpdate = onGameStateUpdate
    }
    
    func play() {
        ball.position = .init(x: 0.5, y: 0.5)
        ball.velocity = .init(x: 0.5, y: 0.2)
        gameState = .playing
    }
    
    func movePlayer(x: CGFloat) {
        movePaddle(player, x: x)
    }
    func moveOpponent(x: CGFloat) {
        movePaddle(opponent, x: x)
    }
    
    private func movePaddle(_ paddle: GameObject, x: CGFloat) {
        paddle.position.x = min(max(paddle.width * 0.5, x), 1 - paddle.width * 0.5)
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
        
        checkCollisions(screenRatio: screenRatio)
    }
    
    private func checkCollisions(screenRatio: CGFloat) {
        if ball.collides(with: player, screenRatio: screenRatio) {
            ball.position.y = player.position.y - (player.height(screenRatio) + ball.height(screenRatio)) * 0.5
            ball.velocity.y *= -1
        }
        else if ball.collides(with: opponent, screenRatio: screenRatio) {
            ball.position.y = opponent.position.y + (opponent.height(screenRatio) + ball.height(screenRatio)) * 0.5
            ball.velocity.y *= -1
        }
        else if ball.collides(with: wallLeft, screenRatio: screenRatio) || ball.collides(with: wallRight, screenRatio: screenRatio) {
            ball.position.x = min(1 - ball.width * 0.5, max(ball.width * 0.5, ball.position.x), ball.position.x)
            ball.velocity.x *= -1
        }
    }
}

