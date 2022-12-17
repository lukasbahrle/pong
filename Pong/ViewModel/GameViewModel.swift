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

protocol GameController {
    var movePlayerPublisher: AnyPublisher<CGFloat, Never> { get }
    var moveOpponentPublisher: AnyPublisher<CGFloat, Never> { get }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize)
}

protocol GameInput {
    func play()
    func movePlayer(x: CGFloat)
    func moveOpponent(x: CGFloat)
    func update(timestamp: TimeInterval, screenRatio: CGFloat)
}

protocol GameOutput {
    var goalPublisher: AnyPublisher<Bool, Never> { get }
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .readyToPlay {
        didSet {
            if gameState == .playing {
                gameInput.play()
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
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let gameInput: GameInput
    private let gameOutput: GameOutput
    private let gameController: GameController
    
    init(gameInput: GameInput, gameOutput: GameOutput, gameController: GameController) {
        self.gameInput = gameInput
        self.gameOutput = gameOutput
        self.gameController = gameController
        
        self.gameController.movePlayerPublisher.sink { [weak self] value in
            guard let self else { return }
            self.gameInput.movePlayer(x: value)
        }
        .store(in: &subscriptions)
        
        self.gameController.moveOpponentPublisher.sink { [weak self] value in
            guard let self else { return }
            self.gameInput.moveOpponent(x: value)
        }
        .store(in: &subscriptions)
        
        self.gameOutput.goalPublisher.sink { isPlayerGoal in
            if isPlayerGoal {
                self.score.playerScores()
            }
            else {
                self.score.opponetScores()
            }
        }
        .store(in: &subscriptions)
    }
    
    func play() {
        guard gameState == .readyToPlay || gameState == .gameOver else { return }
        score.reset()
        gameState = .playing
    }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        gameController.onDrag(dragLocation: dragLocation, screenSize: screenSize)
    }
    
    func update(timestamp: TimeInterval, screenRatio: CGFloat) {
        gameInput.update(timestamp: timestamp, screenRatio: screenRatio)
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
