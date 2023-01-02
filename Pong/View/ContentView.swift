//
//  ContentView.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 9/12/22.
//

import SwiftUI
import Combine

class SimpleGameController: GameController {
    var movePlayerPublisher: AnyPublisher<CGFloat, Never> {
        movePlayerSubject.eraseToAnyPublisher()
    }
    private let movePlayerSubject = PassthroughSubject<CGFloat, Never>()
    
    var moveOpponentPublisher: AnyPublisher<CGFloat, Never> {
        moveOpponentSubject.eraseToAnyPublisher()
    }
    private let moveOpponentSubject = PassthroughSubject<CGFloat, Never>()
    
    func load() async {}
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        let y = dragLocation.y / screenSize.height
        
        if y < 0.5 {
            moveOpponentSubject.send(dragLocation.x / screenSize.width)
        }
        else {
            movePlayerSubject.send(dragLocation.x / screenSize.width)
        }
    }
}

let stateController = GameStateController(score: .initialScore, target: 3)
let disableableStateController = DisableableGameStateController(gameStateController: stateController)
let logic = GameLogic(stateController: stateController)

let activityController = PongActivityController(gameInput: logic, gameOutput: logic) { isEnabled in
    disableableStateController.isEnabled = isEnabled
} updateStateController: { state, score in
    stateController.update(state, score: score)
}

@MainActor
struct ContentView: View {
    @StateObject var game = GameViewModel(gameInput: activityController, gameOutput: activityController, gameController: activityController)
    
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
                    game.onDrag(dragLocation: drag.location, screenSize: UIScreen.main.bounds.size)
                }))
            }
            .ignoresSafeArea()
            
            JoinToPlayView(gameState: game.gameState, action: { game.play() })
        }
        .background(Color.black)
        .task {
            await game.load()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
