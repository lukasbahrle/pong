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
    let player: GameObject = .paddle(true, anchor: .centerTop)
    let opponent: GameObject = .paddle(false, anchor: .centerBottom)
    let wallLeft: GameObject = .wall(.left)
    let wallRight: GameObject = .wall(.right)
    let wallBottom: GameObject = .wall(.bottom)
    let wallTop: GameObject = .wall(.top)
    
    private var lastUpdate: TimeInterval = -1
    
    private let stateController: GameStateControllable
    private var stateCancellable: AnyCancellable?
    
    init(stateController: GameStateControllable) {
        self.stateController = stateController
        
        stateCancellable = self.stateController.publisher.sink { [weak self] (state, _) in
            guard let self else { return }
            
            switch state {
            case .playing:
                self.ball.position = .init(x: 0.5, y: 0.5)
                self.ball.velocity = .init(x: 0.2, y: 0.5)
            default:
                break
            }
        }
    }
    
    func load() {
        ready()
    }
    
    func ready() {
        stateController.ready()
    }
    
    func play(startDirection: StartDirection? = .towardsPlayer) {
        stateController.play(startDirection: startDirection ?? .towardsPlayer)
    }
    
    func movePlayer(x: CGFloat) {
        movePaddle(player, x: x)
    }
    func moveOpponent(x: CGFloat) {
        movePaddle(opponent, x: x)
    }
    
    private func movePaddle(_ paddle: GameObject, x: CGFloat) {
        paddle.position.x = min(max(paddle.width() * 0.5, x), 1 - paddle.width() * 0.5)
    }
    
    func updateBall(position: CGPoint, velocity: CGPoint) {
        ball.position = position
        ball.velocity = velocity
    }
    
    func update(timestamp: TimeInterval, screenSize: CGSize) {
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
        
        checkCollisions(screenSize: screenSize)
    }
    
    private func checkCollisions(screenSize: CGSize) {
        if ball.collides(with: player, screenSize: screenSize), ball.position.y < player.position.y {
            ball.position.y = player.frame(screenSize).minY - ball.height(screenSize) * 0.5
            ball.velocity.y *= -1
        }
        else if ball.collides(with: opponent, screenSize: screenSize), ball.position.y > opponent.position.y {
            ball.position.y = opponent.frame(screenSize).maxY + ball.height(screenSize) * 0.5
            ball.velocity.y *= -1
        }
        else if ball.collides(with: wallLeft, screenSize: screenSize) || ball.collides(with: wallRight, screenSize: screenSize) {
            ball.position.x = min(1 - ball.width(screenSize) * 0.5, max(ball.width(screenSize) * 0.5, ball.position.x))
            
            ball.velocity.x *= -1
        }
        else if ball.collides(with: wallBottom, screenSize: screenSize) {
            stateController.opponentScores()
        }
        else if ball.collides(with: wallTop, screenSize: screenSize) {
            stateController.playerScores()
        }
    }
}

