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
    case gameOver
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .readyToPlay
    
    private(set) lazy var logic = GameLogic(targetScore: 3, onScoreUpdate: { score in }, onGameStateUpdate: { [weak self] state in
        guard let self else { return }
        switch state {
        case .readyToPlay:
            self.gameState = .readyToPlay
        case .playing:
            self.gameState = .playing
        case .gameOver:
            self.gameState = .gameOver
        }
    })
    
    func play() {
        guard gameState == .readyToPlay || gameState == .gameOver else { return }
        logic.play()
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
}
