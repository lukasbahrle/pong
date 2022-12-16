//
//  GameViewModel.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import Foundation

enum GameState {
    case readyToPlay
    case playing
    case goal
    case gameOver
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
    
    private(set) lazy var logic = GameLogic { [weak self] isPlayerGoal in
        guard let self else { return }
        if isPlayerGoal {
            self.score.playerScores()
        }
        else {
            self.score.opponetScores()
        }
    }
    
    func play() {
        guard gameState == .readyToPlay || gameState == .gameOver else { return }
        score.reset()
        gameState = .playing
    }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        let y = dragLocation.y / screenSize.height
        
        if y < 0.5 {
            logic.moveOpponent(x: dragLocation.x / screenSize.width)
        }
        else {
            logic.movePlayer(x: dragLocation.x / screenSize.width)
        }
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
