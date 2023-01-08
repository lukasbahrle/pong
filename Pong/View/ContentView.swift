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
    
    var body: some View {
        VStack(spacing: 0) {
            GameView(game: gameViewModel(config1.messenger, config1.participantsConfig(opponent: config2.participantId, isFirst: true)))
                .padding(.horizontal, 50)
            GameView(game: gameViewModel(config2.messenger, config2.participantsConfig(opponent: config1.participantId, isFirst: false)))
                .padding(.horizontal, 250)
        }
        .background(Color.gray)
    }
}

@MainActor
struct GameView: View {
    @ObservedObject var game: GameViewModel
    
    private var scoreOpacity: Double {
        switch game.gameState {
        case .notReady, .ready:
            return 0
        case .playing:
            return 0.2
        case .goal, .gameOver:
            return 1.0
        }
    }
    
    private var linesOpacity: Double {
        switch game.gameState {
        case .playing:
            return 1.0
        default:
            return 0
        }
    }
    
    private let linesColor = Color(white: 0.2)
    
    private var scoreScale: Double {
        switch game.gameState {
        case .goal:
            return 1.4
        default:
            return 1.2
        }
    }
    
    private var message: String {
        switch game.gameState {
        case .goal:
            return "Goal"
        case .gameOver:
            return game.score.player > game.score.opponent ? "You win" : "You lose"
        default:
            return ""
        }
    }
    
    @State var isMessage: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 0) {
                    Text("\(game.score.opponent)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text("\(game.score.player)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(.white)
                .opacity(scoreOpacity)
                .animation(.easeOut, value: game.gameState)
                
                VStack {
                    if !message.isEmpty {
                        Text(message)
                            .font(.largeTitle)
                            .scaleEffect(1.5)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(), value: game.gameState)
                
                Divider()
                    .frame(height: 2)
                    .overlay(linesColor.opacity(linesOpacity))
                
                Circle()
                    .strokeBorder(linesColor.opacity(linesOpacity),lineWidth: 2)
                    .frame(width: 100, height: 100)
                    
                
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        game.update(timestamp: timeline.date.timeIntervalSinceReferenceDate, screenRatio: size.width/size.height)
                        game.draw(context: context, canvasSize: size)
                    }
                    .gesture(DragGesture(minimumDistance: 0).onChanged({ drag in
                        game.onDrag(dragLocation: drag.location, screenSize: proxy.size)
                    }))
                }
                //.ignoresSafeArea()
                
                JoinToPlayView(gameState: game.gameState, action: { game.play() })
            }
            .background(Color.black)
            .task {
                await game.load()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
