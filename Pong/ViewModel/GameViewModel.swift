//
//  GameViewModel.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import Foundation

class GameViewModel: ObservableObject {
    let logic = GameLogic(targetScore: 3, onScoreUpdate: { score in }, onGameStateUpdate: { state in })
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        logic.movePlayer(x: dragLocation.x / screenSize.width)
    }
    
    func update(timestamp: TimeInterval, screenRatio: CGFloat) {
        logic.update(timestamp: timestamp, screenRatio: screenRatio)
    }
}
