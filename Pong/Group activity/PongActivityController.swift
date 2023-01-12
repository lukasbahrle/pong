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
    
    private var messenger: PongGroupSessionMessenger?
    private var udpMessenger: PongGroupSessionMessenger?
    
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
   
    private let gameInput: GameInput
    private let gameOutput: GameOutput
    private let setStateControllerIsEnabled: (Bool) -> Void
    private let updateStateController: (GameState, (Int, Int)) -> Void
    
    private var groupSession: PongGroupSession?
    
    private let groupActivity: PongGroupActivity
    
    private var playersSubject = CurrentValueSubject<(player: UUID?, opponent: UUID?), Never>((player: nil, opponent: nil))
    
    private var isInControl: Bool = false {
        didSet {
            setStateControllerIsEnabled(isInControl)
        }
    }
    
    private var isActive: Bool {
        guard let groupSession else { return false }
        
        return groupSession.state == .joined
    }
    
    init(groupActivity: PongGroupActivity, gameInput: GameInput, gameOutput: GameOutput, setStateControllerIsEnabled: @escaping (Bool) -> Void, updateStateController: @escaping (GameState, (Int, Int)) -> Void) {
        self.groupActivity = groupActivity
        self.gameInput = gameInput
        self.gameOutput = gameOutput
        self.setStateControllerIsEnabled = setStateControllerIsEnabled
        self.updateStateController = updateStateController
        
        self.gameOutput.statePublisher.sink { [weak self] (state, score) in
            guard let self, self.isInControl, let messenger = self.messenger, let playerId = self.playersSubject.value.player, let opponentId = self.playersSubject.value.opponent  else { return }
            
            messenger.send(GameStateMessage(score: [
                playerId: score.player,
                opponentId: score.opponent
            ], state: state), completion: { _ in })
        }
        .store(in: &subscriptions)
    }
    
    // MARK: - Session
    
    private func configureGroupSession(_ groupSession: PongGroupSession) {
        isInControl = false
        
        let messenger = groupSession.messenger(deliveryMode: .reliable)
        self.messenger = messenger

        let udpMessenger = groupSession.messenger(deliveryMode: .unreliable)
        self.udpMessenger = udpMessenger
        
        self.groupSession = groupSession
        
        groupSession.statePublisher
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                    self.reset()
                }
            }
            .store(in: &subscriptions)
        
        groupSession.activeParticipantsPublisher
            .sink { [weak self] participants in
                self?.onParticipantsListUpdate(participants, localParticipant: groupSession.localPongParticipant)
            }
            .store(in: &subscriptions)
        
        udpMessenger.messages(of: GameUpdateMessage.self)
            .sink { [weak self] message in
                guard let self else { return }
                self.moveOpponent(x: 1 - message.playerPaddle)
                
                guard !self.isInControl else { return }

                let ballVelocity = message.ball.velocity * -1

                if self.ball.velocity != ballVelocity {
                    self.updateBall(position: 1 - message.ball.position, velocity: ballVelocity)
                }
            }
            .store(in: &subscriptions)
        
        messenger.messages(of: GameStateMessage.self)
            .sink { [weak self] message in
                
                guard let self else { return }
                
                guard !self.isInControl else {
                    if message.state == .playing { self.play() }
                    return
                }
                
                guard let playerId = self.playersSubject.value.player, let playerScore = message.score[playerId], let opponentId = self.playersSubject.value.opponent, let opponentScore = message.score[opponentId] else { return }
                
                self.updateStateController(message.state, (playerScore, opponentScore))
                
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
    
    private func onParticipantsListUpdate(_ participants: Set<PongParticipant>, localParticipant: PongParticipant) {
        guard participants.contains(localParticipant) else {
            playersSubject.value = (nil, nil)
            return
        }
        
        if participants.count == 1 {
            isInControl = true
            playersSubject.value = (localParticipant.id, nil)
        }
        else if participants.count > 1 {
            let opponent = participants.first { participant in
                participant != localParticipant
            }
            playersSubject.value = (localParticipant.id, opponent?.id)
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
        playersSubject.value = (nil, nil)
        
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
        
        for await session in groupActivity.sessionsPublisher.values {
            configureGroupSession(session)
        }
    }
    
    func ready() {
        gameInput.ready()
    }
    
    func play(startDirection: StartDirection? = nil) {
        if !isActive {
            self.startSharing()
        }
        else if isInControl {
            gameInput.play(startDirection: isInControl ? .towardsPlayer : .towardsOpponent)
        }
        else if let messenger {
            messenger.send(GameStateMessage(score: [:], state: .playing), completion: { _ in })
        }
    }
    
    func movePlayer(x: CGFloat) {
        gameInput.movePlayer(x: x)
    }
    
    func moveOpponent(x: CGFloat) {
        gameInput.moveOpponent(x: x)
    }
    
    func updateBall(position: CGPoint, velocity: CGPoint) {
        gameInput.updateBall(position: position, velocity: velocity)
    }
    
    func update(timestamp: TimeInterval, screenSize: CGSize) {
        gameInput.update(timestamp: timestamp, screenSize: screenSize)
        
        guard let groupSession = groupSession else {
            return
        }
        
        udpMessenger?.send(
            GameUpdateMessage(player: groupSession.localPongParticipant.id, playerPaddle: player.position.x, ball: .init(position: ball.position, velocity: ball.velocity)),
            completion: { _ in })
    }
}

// MARK: - GameOutput
extension PongActivityController: GameOutput {
    var ball: GameObject {
        gameOutput.ball
    }
    
    var player: GameObject {
        gameOutput.player
    }
    
    var opponent: GameObject {
        gameOutput.opponent
    }
    
    var statePublisher: AnyPublisher<(state: GameState, score: (player: Int, opponent: Int)), Never> {
        gameOutput.statePublisher.combineLatest(playersSubject).map { input in
            let playerId = input.1.player
            let opponentId = input.1.opponent
            let score = input.0.score
            
            if playerId == nil, opponentId == nil {
                return (state: .notReady(.all), score: score)
            }
            else if playerId == nil {
                return (state: .notReady(.player), score: score)
            }
            else if opponentId == nil {
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
