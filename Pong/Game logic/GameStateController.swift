//
//  GameStateController.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 27/12/22.
//

import Foundation
import Combine

enum GameState {
    case ready
    case playing
    case goal
    case gameOver
}

class GameStateController {
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
    private let stateSubject = CurrentValueSubject<GameState, Never>(.ready)
    private var score: GameScore
    private var target: Int
    
    internal init(score: GameScore, target: Int) {
        self.score = score
        self.target = target
    }
    
    func ready() {
        score.reset()
        stateSubject.value = .ready
    }
    
    func play() -> Bool {
        guard state == .goal || state == .ready else {
            return false
        }
        stateSubject.value = .playing
        return true
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
