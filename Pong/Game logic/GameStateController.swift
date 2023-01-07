//
//  GameStateController.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 27/12/22.
//

import Foundation
import Combine

enum PlayerType: Codable {
    case player
    case opponent
    case all
}

enum GameState: Equatable, Codable {
    case notReady(PlayerType)
    case ready
    case playing
    case goal
    case gameOver
}

enum StartDirection: Codable {
    case towardsPlayer
    case towardsOpponent
}

protocol GameStateControllable {
    var publisher: AnyPublisher<(state: GameState, score: (player: Int, opponent: Int)), Never> { get }
    
    var state: GameState { get }
    
    func ready()
    func play(startDirection: StartDirection)
    func playerScores()
    func opponentScores()
}

class DisableableGameStateController: GameStateControllable {
    private let gameStateController: GameStateControllable
    var isEnabled: Bool
    
    init(gameStateController: GameStateControllable, isEnabled: Bool = true) {
        self.gameStateController = gameStateController
        self.isEnabled = isEnabled
    }
    
    var publisher: AnyPublisher<(state: GameState, score: (player: Int, opponent: Int)), Never> {
        gameStateController.publisher
    }
    
    var state: GameState {
        gameStateController.state
    }
    
    func ready() {
        guard isEnabled else { return }
        gameStateController.ready()
    }
    
    func play(startDirection: StartDirection) {
        guard isEnabled else { return }
        gameStateController.play(startDirection: startDirection)
    }
    
    func playerScores() {
        guard isEnabled else { return }
        gameStateController.playerScores()
    }
    
    func opponentScores() {
        guard isEnabled else { return }
        gameStateController.opponentScores()
    }
}


class GameStateController: GameStateControllable {
    var publisher: AnyPublisher<(state: GameState, score: (player: Int, opponent: Int)), Never> {
        stateSubject
            .map { [weak self] state in
                guard let self = self else { return (state: state, score: (player: 0, opponent: 0)) }
                return (state: state, score: (player: self.score.player, opponent: self.score.opponent))
            }
            .eraseToAnyPublisher()
    }
    
    var state: GameState {
        stateSubject.value
    }
    private let stateSubject = CurrentValueSubject<GameState, Never>(.notReady(.all))
    private var score: GameScore
    private var target: Int
    
    internal init(score: GameScore, target: Int) {
        self.score = score
        self.target = target
    }
    
    func update(_ state: GameState, score: (player: Int, opponent: Int)) {
        self.score.player = score.player
        self.score.opponent = score.opponent
        stateSubject.value = state
    }
    
    func ready() {
        score.reset()
        stateSubject.value = .ready
    }
    
    func play(startDirection: StartDirection) {
        guard state == .goal || state == .ready else {
            return
        }
        stateSubject.value = .playing
    }
    
    func playerScores() {
        onGoal(isPlayer: true)
    }
    
    func opponentScores() {
        onGoal(isPlayer: false)
    }
    
    private func onGoal(isPlayer: Bool) {
        guard state == .playing else {
            return
        }
        
        if isPlayer {
            score.playerScores()
        }
        else {
            score.opponentScores()
        }
        
        if score.isGameOver(target: target) {
            stateSubject.value = .gameOver
        }
        else {
            stateSubject.value = .goal
        }
    }
}
