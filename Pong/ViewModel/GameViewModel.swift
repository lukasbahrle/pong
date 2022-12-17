//
//  GameViewModel.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import Foundation
import Combine

enum GameState {
    case readyToPlay
    case playing
    case goal
    case gameOver
}

protocol GameInputGenerator {
    var movePlayerPublisher: AnyPublisher<CGFloat, Never> { get }
    var moveOpponentPublisher: AnyPublisher<CGFloat, Never> { get }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize)
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .readyToPlay {
        didSet {
            if gameState == .playing {
                logic.play()
            }
        }
    }
    @Published var score: GameScore = .initialScore {
        didSet {
            if score.isGameOver(target: 3) {
                onGameOver()
            }
            else if score.player > 0 || score.opponent > 0 {
                onGoal()
            }
        }
    }
    
    private let inputGenerator: GameInputGenerator
    
    private var subscriptions = Set<AnyCancellable>()
    
    private(set) lazy var logic = GameLogic { [weak self] isPlayerGoal in
        guard let self else { return }
        if isPlayerGoal {
            self.score.playerScores()
        }
        else {
            self.score.opponetScores()
        }
    }
    
    init(gameInputGenerator: GameInputGenerator) {
        self.inputGenerator = gameInputGenerator
        
        self.inputGenerator.movePlayerPublisher.sink { [weak self] value in
            guard let self else { return }
            self.logic.movePlayer(x: value)
        }
        .store(in: &subscriptions)
        
        self.inputGenerator.moveOpponentPublisher.sink { [weak self] value in
            guard let self else { return }
            self.logic.moveOpponent(x: value)
        }
        .store(in: &subscriptions)
    }
    
    func play() {
        guard gameState == .readyToPlay || gameState == .gameOver else { return }
        score.reset()
        gameState = .playing
    }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        inputGenerator.onDrag(dragLocation: dragLocation, screenSize: screenSize)
    }
    
    func update(timestamp: TimeInterval, screenRatio: CGFloat) {
        logic.update(timestamp: timestamp, screenRatio: screenRatio)
    }
    
    private func onGoal() {
        gameState = .goal
        Task {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            gameState = .playing
        }
    }
    
    private func onGameOver() {
        gameState = .gameOver
        Task {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
            gameState = .readyToPlay
        }
    }
}
