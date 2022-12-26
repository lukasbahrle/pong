//
//  GameLogic.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation
import Combine

class GameLogic: GameInput, GameOutput {
    enum State {
        case ready
        case playing
        case goal
        case gameOver
    }
    
    var scorePublisher: AnyPublisher<(player: Int, opponent: Int, isGameOver: Bool), Never> {
        scoreSubject
            .map({[weak self] score in
                guard let self = self else { return (player: 0, opponent: 0, isGameOver: false) }
                return (player: score.player, opponent: score.opponent, isGameOver: score.isGameOver(target: self.target))
            })
            .eraseToAnyPublisher()
    }
    
    private let scoreSubject = CurrentValueSubject<GameScore, Never>(.initialScore)
    private let target: Int
    
    let ball: GameObject = .ball
    let player: GameObject = .paddle(true)
    let opponent: GameObject = .paddle(false)
    let wallLeft: GameObject = .wall(.left)
    let wallRight: GameObject = .wall(.right)
    let wallBottom: GameObject = .wall(.bottom)
    let wallTop: GameObject = .wall(.top)
    
    private var lastUpdate: TimeInterval = -1
    private var state: State = .ready
    
    init(target: Int) {
        self.target = target
    }
    
    func load() {}
    
    func play(reset: Bool) {
        if reset || state == .gameOver{
            scoreSubject.value.reset()
        }
        state = .playing
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
        
        guard state == .playing else {
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
            onGoal(isPlayer: false)
        }
        else if ball.collides(with: wallTop, screenRatio: screenRatio) {
            onGoal(isPlayer: true)
        }
    }
    
    private func onGoal(isPlayer: Bool) {
        if isPlayer {
            state = scoreSubject.value.player + 1 >= target ? .gameOver : .goal
            scoreSubject.value.playerScores()
        }
        else {
            state = scoreSubject.value.opponent + 1 >= target ? .gameOver : .goal
            scoreSubject.value.opponentScores()
        }
    }
}

