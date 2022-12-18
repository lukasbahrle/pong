//
//  ActivityController.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 18/12/22.
//

import Foundation
import Combine
import GroupActivities

class PongActivityController : GameController{
    private let movePlayerSubject = PassthroughSubject<CGFloat, Never>()
    private let moveOpponentSubject = PassthroughSubject<CGFloat, Never>()
    private let goalSubject = PassthroughSubject<Bool, Never>()
    
    private let gameInput: GameInput
    
    init(gameInput: GameInput) {
        self.gameInput = gameInput
    }
    
    // MARK: - Session
    
    private func configureGroupSession(_ groupSession: GroupSession<PongActivity>) {}
}

// MARK: - Game Input

extension PongActivityController: GameInput {
    func load() {
        Task {
            for await session in PongActivity.sessions() {
                configureGroupSession(session)
            }
        }
        gameInput.load()
    }
    
    func play() {
        gameInput.play()
    }
    
    func movePlayer(x: CGFloat) {
        gameInput.movePlayer(x: x)
    }
    
    func moveOpponent(x: CGFloat) {
        gameInput.moveOpponent(x: x)
    }
    
    func update(timestamp: TimeInterval, screenRatio: CGFloat) {
        gameInput.update(timestamp: timestamp, screenRatio: screenRatio)
    }
}

// MARK: - GameOutput

extension PongActivityController: GameOutput {
    var goalPublisher: AnyPublisher<Bool, Never> {
        goalSubject.eraseToAnyPublisher()
    }
}

// MARK: - GameController

extension PongActivityController  {
    var movePlayerPublisher: AnyPublisher<CGFloat, Never> {
        movePlayerSubject.eraseToAnyPublisher()
    }
    
    var moveOpponentPublisher: AnyPublisher<CGFloat, Never> {
        moveOpponentSubject.eraseToAnyPublisher()
    }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        movePlayerSubject.send(dragLocation.x / screenSize.width)
    }
}
