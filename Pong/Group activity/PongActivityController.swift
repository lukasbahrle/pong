//
//  ActivityController.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 18/12/22.
//

import Foundation
import Combine
import GroupActivities

class PongActivityController {
    private let movePlayerSubject = PassthroughSubject<CGFloat, Never>()
    private let moveOpponentSubject = PassthroughSubject<CGFloat, Never>()
    
    private var messenger: GroupSessionMessenger?
    private var udpMessenger: GroupSessionMessenger?
    
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
   
    private let gameInput: GameInput
    private let gameOutput: GameOutput
    private let setStateControllerEnabled: (Bool) -> Void
    
    private var groupSession: GroupSession<PongActivity>?
    
    init(gameInput: GameInput, gameOutput: GameOutput, setStateControllerEnabled: @escaping (Bool) -> Void) {
        self.gameInput = gameInput
        self.gameOutput = gameOutput
        self.setStateControllerEnabled = setStateControllerEnabled
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
    
    func ready() {
        gameInput.ready()
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
    var statePublisher: AnyPublisher<(state: GameState, score: (player: Int, opponent: Int)), Never> {
        gameOutput.statePublisher
    }
}

// MARK: - GameController

extension PongActivityController: GameController {
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
