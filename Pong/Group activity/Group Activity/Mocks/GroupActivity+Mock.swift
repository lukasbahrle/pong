//
//  MocksGroupActivity.swift
//  Pong
//
//  Created by Bahrle, Lukas on 17/1/23.
//

import Foundation
import Combine
import GroupActivities

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
    
    var state: GroupSession<PongActivity>.State { .joined }
    
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
