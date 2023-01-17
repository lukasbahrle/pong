//
//  ContentView.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 9/12/22.
//

import SwiftUI
import Combine
import GroupActivities

struct MockPongGroupSessionConfiguration {
    let participantId = UUID()
    let messenger = MockPongGroupSessionMessenger()
    
    func participantsConfig(opponent: UUID, isFirst: Bool) -> MockGroupSessionParticipants {
        .init(local: PongParticipant(id: participantId), opponent: PongParticipant(id: opponent), isFirst: isFirst)
    }
}

let config1 = MockPongGroupSessionConfiguration()
let config2 = MockPongGroupSessionConfiguration()

@MainActor
struct ContentView: View {
    var gameViewModel: (PongGroupSessionMessenger, MockGroupSessionParticipants) -> GameViewModel = { messenger, participantsConfig in
        
        config1.messenger.receiver = config2.messenger
        config2.messenger.receiver = config1.messenger
        
        let stateController = GameStateController(score: .initialScore, target: 3)
        let disableableStateController = DisableableGameStateController(gameStateController: stateController)
        let logic = GameLogic(stateController: disableableStateController)


        let activityController = PongActivityController(groupActivity: MockPongGroupActivity(messenger: {messenger}, participantsConfig: participantsConfig), gameInput: logic, gameOutput: logic) { isEnabled in
            disableableStateController.isEnabled = isEnabled
        } updateStateController: { state, score in
            stateController.update(state, score: score)
        }
        
        return GameViewModel(gameInput: activityController, gameOutput: activityController, gameController: activityController)
    }
    
    var prodGameViewModel: () -> GameViewModel = {
        
        let stateController = GameStateController(score: .initialScore, target: 3)
        let disableableStateController = DisableableGameStateController(gameStateController: stateController)
        let logic = GameLogic(stateController: disableableStateController)

        let activityController = PongActivityController(groupActivity: LivePongGroupActivity(), gameInput: logic, gameOutput: logic) { isEnabled in
            disableableStateController.isEnabled = isEnabled
        } updateStateController: { state, score in
            stateController.update(state, score: score)
        }
        
        return GameViewModel(gameInput: activityController, gameOutput: activityController, gameController: activityController)
    }
    
    
    
    var body: some View {
//        VStack(spacing: 0) {
//            GameView(game: gameViewModel(config1.messenger, config1.participantsConfig(opponent: config2.participantId, isFirst: true)))
//            GameView(game: gameViewModel(config2.messenger, config2.participantsConfig(opponent: config1.participantId, isFirst: false)))
//                .padding(.horizontal, 250)
//        }
//        .background(Color.gray)
        GameView(game: prodGameViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
