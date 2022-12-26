//
//  ActivityController.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 18/12/22.
//

import Foundation
import Combine
import GroupActivities

class PongActivityController{
    private let playerIsActiveSubject = CurrentValueSubject<Bool, Never>(false)
    private let opponentIsActiveSubject = CurrentValueSubject<Bool, Never>(false)
    
    private let movePlayerSubject = PassthroughSubject<CGFloat, Never>()
    private let moveOpponentSubject = PassthroughSubject<CGFloat, Never>()
    private let scoreSubject = PassthroughSubject<(player: Int, opponent: Int, isGameOver: Bool), Never>()
    
    private var messenger: GroupSessionMessenger?
    private var udpMessenger: GroupSessionMessenger?
    
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
   
    private let gameInput: GameInput
    
    private var groupSession: GroupSession<PongActivity>?
    
    init(gameInput: GameInput) {
        self.gameInput = gameInput
    }
    
    // MARK: - Session
    
    private func configureGroupSession(_ groupSession: GroupSession<PongActivity>) {
        let messenger = GroupSessionMessenger(session: groupSession, deliveryMode: .unreliable)
        self.messenger = messenger
        
        let udpMessenger = GroupSessionMessenger(session: groupSession, deliveryMode: .unreliable)
        self.udpMessenger = udpMessenger
        
        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                    self.reset()
                }
            }
            .store(in: &subscriptions)
        
        groupSession.$activeParticipants
            .sink { participants in
                
            }
            .store(in: &subscriptions)
        
        groupSession.join()
    }
    
    private func startSharing() {
        Task {
            do {
                _ = try await PongActivity().activate()
            } catch {
                print("Failed to activate Pong activity: \(error)")
            }
        }
    }
}

extension PongActivityController {
    private func reset() {
        messenger = nil
        udpMessenger = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []
        if groupSession != nil {
            groupSession?.leave()
            groupSession = nil
            self.startSharing()
        }
    }
}

// MARK: - Game Input

extension PongActivityController: GameInput {
    func load() async {
        for await session in PongActivity.sessions() {
            configureGroupSession(session)
        }
        await gameInput.load()
    }
    
    func play(reset: Bool) {
        gameInput.play(reset: reset)
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
    var scorePublisher: AnyPublisher<(player: Int, opponent: Int, isGameOver: Bool), Never> {
        scoreSubject.eraseToAnyPublisher()
    }
}

// MARK: - GameController

extension PongActivityController: GameController {
    var playerIsActivePublisher: AnyPublisher<Bool, Never> {
        playerIsActiveSubject.eraseToAnyPublisher()
    }
    
    var opponentIsActivePublisher: AnyPublisher<Bool, Never> {
        opponentIsActiveSubject.eraseToAnyPublisher()
    }
    
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
