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
    
    private var participantsSubject = CurrentValueSubject<(player: UUID?, opponent: UUID?), Never>((player: nil, opponent: nil))
    private var playerId: UUID? {
        participantsSubject.value.player
    }
    private var opponentId: UUID? {
        participantsSubject.value.opponent
    }
    
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
            .sink { [weak self] participants in
                self?.onParticipantsListUpdate(participants)
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
    
    private func onParticipantsListUpdate(_ participants: Set<Participant>) {
        
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
        await gameInput.load()
        for await session in PongActivity.sessions() {
            configureGroupSession(session)
        }
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
        gameOutput.statePublisher.combineLatest(participantsSubject).map { input in
            let playerId = input.1.player
            let opponentId = input.1.opponent
            let score = input.0.score
            
            if playerId == nil, opponentId == nil {
                return (state: .notReady(.all), score: score)
            }
            else if self.playerId == nil {
                return (state: .notReady(.player), score: score)
            }
            else if self.opponentId == nil {
                return (state: .notReady(.opponent), score: score)
            }
            
            return (state: input.0.state, score: score)
        }
        .eraseToAnyPublisher()
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
