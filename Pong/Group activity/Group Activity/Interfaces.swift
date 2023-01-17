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
    var state: GroupSession<PongActivity>.State { get }
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
