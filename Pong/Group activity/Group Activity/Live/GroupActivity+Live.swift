//
//  GroupActivity+Live.swift
//  Pong
//
//  Created by Bahrle, Lukas on 17/1/23.
//

import Combine
import GroupActivities

struct LivePongGroupActivity: PongGroupActivity {
    var sessionsPublisher: AnyPublisher<PongGroupSession, Never> {
        subject
            .handleEvents(
                receiveSubscription: { _ in
                    start()
                }
            )
            .eraseToAnyPublisher()
    }
    private let subject = PassthroughSubject<PongGroupSession, Never>()
    
    private func start() {
        Task {
            for await session in PongActivity.sessions() {
                subject.send(session)
            }
        }
    }
}

extension GroupSession<PongActivity>: PongGroupSession {
    var localPongParticipant: PongParticipant {
        PongParticipant(id: localParticipant.id)
    }
    
    var statePublisher: AnyPublisher<GroupSession<PongActivity>.State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    var activeParticipantsPublisher: AnyPublisher<Set<PongParticipant>, Never> {
        $activeParticipants.map { participants in
            Set(participants.map {PongParticipant(id: $0.id)})
        }.eraseToAnyPublisher()
    }
    
    func messenger(deliveryMode: GroupSessionMessenger.DeliveryMode) -> PongGroupSessionMessenger {
        GroupSessionMessenger(session: self, deliveryMode: deliveryMode)
    }
}

extension GroupSessionMessenger: PongGroupSessionMessenger {
    func send<Message>(_ value: Message, completion: @escaping (Error?) -> Void) where Message : Decodable, Message : Encodable {
        send(value, to: .all, completion: completion)
    }
    
    func messages<Message: Codable>(of type: Message.Type) -> AnyPublisher<Message, Never> {
        let subject = PassthroughSubject<Message, Never>()
        
        let stream = {
            Task {
                for await (message, _) in self.messages(of: type) {
                    subject.send(message)
                }
            }
        }
        
        var task: Task<(), Never>?
        
        return subject.handleEvents(
            receiveSubscription: { _ in
                task = stream()
            },
            receiveCancel: {
                task?.cancel()
            }
        )
        .eraseToAnyPublisher()
    }
    
    private func start<Message: Codable>(type: Message.Type, subject: PassthroughSubject<Message, Never>) async {
        for await (message, _) in self.messages(of: type) {
            subject.send(message)
        }
    }
}
