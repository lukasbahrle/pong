//
//  GameLogic.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation
import Combine

class GameLogic: GameInput, GameOutput {
    var statePublisher: AnyPublisher<(state: GameState, score: (player: Int, opponent: Int)), Never> {
        stateController.publisher
            .eraseToAnyPublisher()
    }
    
    let ball: GameObject = .ball
    let player: GameObject = .paddle(true)
    let opponent: GameObject = .paddle(false)
    let wallLeft: GameObject = .wall(.left)
    let wallRight: GameObject = .wall(.right)
    let wallBottom: GameObject = .wall(.bottom)
    let wallTop: GameObject = .wall(.top)
    
    private var lastUpdate: TimeInterval = -1
    
    private let stateController: GameStateControllable
    
    init(stateController: GameStateControllable) {
        self.stateController = stateController
    }
    
    func load() {}
    
    func ready() {
        stateController.ready()
    }
    
    func play() {
        guard stateController.play() else { return }
        
        ball.position = .init(x: 0.5, y: 0.5)
        ball.velocity = .init(x: 0.5, y: 0.2)
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
        
        ball.update(deltaTime: deltaTime)
        player.update(deltaTime: deltaTime, move: false)
        opponent.update(deltaTime: deltaTime, move: false)
        
        guard stateController.state == .playing else {
            return
        }
        
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
        else if ball.collides(with: wallBottom, screenRatio: screenRatio) {
            stateController.opponentScores()
        }
        else if ball.collides(with: wallTop, screenRatio: screenRatio) {
            stateController.playerScores()
        }
    }
}

