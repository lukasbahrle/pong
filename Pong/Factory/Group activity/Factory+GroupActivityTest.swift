//
//  Factory+GroupActivityTest.swift
//  Pong
//
//  Created by Bahrle, Lukas on 20/1/23.
//

import Foundation
import Combine

extension Factory {
    @MainActor static func groupActivityTest(_ gameViewModelFactory: @MainActor (PongGroupActivity) -> GameViewModel = Self.groupActivity) -> (local: GameViewModel, remote: GameViewModel) {
        
        let localConfig = MockPongGroupSessionConfiguration()
        let remoteConfig = MockPongGroupSessionConfiguration()
        
        let localGroupActivity = MockPongGroupActivity(messenger: {localConfig.messenger}, participantsConfig: localConfig.participantsConfig(opponent: remoteConfig.participantId, isFirst: true))
        
        let remoteGroupActivity = MockPongGroupActivity(messenger: {remoteConfig.messenger}, participantsConfig: remoteConfig.participantsConfig(opponent: localConfig.participantId, isFirst: false))
        
        localConfig.messenger.output = remoteConfig.messenger
        remoteConfig.messenger.output = localConfig.messenger
        
        return (local: gameViewModelFactory(localGroupActivity), remote: gameViewModelFactory(remoteGroupActivity))
    }
    
    private struct MockPongGroupSessionConfiguration {
        let participantId = UUID()
        let messenger = MockPongGroupSessionMessenger()
        
        func participantsConfig(opponent: UUID, isFirst: Bool) -> MockGroupSessionParticipants {
            .init(local: PongParticipant(id: participantId), opponent: PongParticipant(id: opponent), isFirst: isFirst)
        }
    }
}
