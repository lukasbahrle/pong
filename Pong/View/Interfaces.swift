//
//  Interfaces.swift
//  Pong
//
//  Created by Bahrle, Lukas on 5/1/23.
//

import Foundation
import Combine
import GroupActivities

struct PongParticipant: Hashable {
    let id: UUID
}

protocol PongGroupActivity {
    var sessionsPublisher: AnyPublisher<PongGroupSession, Never> { get }
}

protocol PongGroupSession {
    var localPongParticipant: PongParticipant { get }
    var statePublisher: AnyPublisher<GroupSession<PongActivity>.State, Never> { get }
    func messenger(deliveryMode: GroupSessionMessenger.DeliveryMode) -> PongGroupSessionMessenger
    var activeParticipantsPublisher: AnyPublisher<Set<PongParticipant>, Never> { get }
    func join()
    func leave()
}

protocol PongGroupSessionMessenger {
    var deliveryMode: GroupSessionMessenger.DeliveryMode { get }
    func send<Message: Codable>(_ message: Message, completion: @escaping (Error?) -> Void)
    func messages<Message: Codable>(of type: Message.Type) -> AnyPublisher<Message, Never>
}


// MARK: - Prod

struct ProdPongGroupActivity: PongGroupActivity {
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

// MARK: - Mock

struct MockPongGroupActivity: PongGroupActivity {
    let messenger: () -> PongGroupSessionMessenger
    let participantsConfig: MockGroupSessionParticipants
    
    var sessionsPublisher: AnyPublisher<PongGroupSession, Never> {
        Just(MockPongGroupSession(messenger: messenger, participantsConfig: participantsConfig)).delay(for: 2, scheduler: RunLoop.main).eraseToAnyPublisher()
    }
}

struct MockGroupSessionParticipants {
    let local: PongParticipant
    let opponent: PongParticipant
    let isFirst: Bool
}

struct MockPongGroupSession: PongGroupSession {
    var localPongParticipant: PongParticipant {
        participantsConfig.local
    }
    let messenger: () -> PongGroupSessionMessenger
    let participantsConfig: MockGroupSessionParticipants
    
    var statePublisher: AnyPublisher<GroupSession<PongActivity>.State, Never> {
        Just(.joined).eraseToAnyPublisher()
    }
    
    var activeParticipantsPublisher: AnyPublisher<Set<PongParticipant>, Never> {
        participantsConfig.isFirst ? .first(local: participantsConfig.local, opponent: participantsConfig.opponent) : .second(local: participantsConfig.local, opponent: participantsConfig.opponent)
    }
    
    func messenger(deliveryMode: GroupSessionMessenger.DeliveryMode) -> PongGroupSessionMessenger {
        messenger()
    }
    
    func join() {}
    func leave() {}
}

extension AnyPublisher<Set<PongParticipant>, Never> {
    static func first(local: PongParticipant, opponent: PongParticipant) -> Self {
        Just(Set([local]))
            .append(Just(Set([local, opponent])).delay(for: 2, scheduler: RunLoop.main))
            .eraseToAnyPublisher()
    }
    
    static func second(local: PongParticipant, opponent: PongParticipant) -> Self {
        Just(Set([local, opponent])).delay(for: 2, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

class MockPongGroupSessionMessenger: PongGroupSessionMessenger {
    var receiver: MockPongGroupSessionMessenger? = nil
    
    var subjects: [String: any Subject] = [:]
    
    var deliveryMode: GroupSessionMessenger.DeliveryMode {
        .reliable
    }
    
    func send<Message>(_ message: Message, completion: @escaping (Error?) -> Void) where Message : Decodable, Message : Encodable {
        
        guard let subject = receiver?.subjects[String(describing: Message.self)] as? PassthroughSubject<Message, Never> else {
            return
        }
        subject.send(message)
    }
    
    func messages<Message>(of type: Message.Type) -> AnyPublisher<Message, Never> where Message : Decodable, Message : Encodable {
        
        let subject = PassthroughSubject<Message, Never>()
        subjects[String(describing: Message.self)] = subject
        
        return subject.eraseToAnyPublisher()
    }
}
