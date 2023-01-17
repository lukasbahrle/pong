//
//  GameView.swift
//  Pong
//
//  Created by Bahrle, Lukas on 17/1/23.
//

import SwiftUI

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
            return 0.0
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
                
                Divider()
                    .frame(height: 2)
                    .overlay(linesColor.opacity(linesOpacity))
                
                Circle()
                    .strokeBorder(linesColor.opacity(linesOpacity),lineWidth: 2)
                    .frame(width: 100, height: 100)
                    
                VStack {
                    if !message.isEmpty {
                        Text(message)
                            .font(.largeTitle)
                            .scaleEffect(1.5)
                            .fontWeight(.black)
                            .foregroundColor(.blue)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(), value: game.gameState)
                
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        game.update(timestamp: timeline.date.timeIntervalSinceReferenceDate, screenSize: size)
                        game.draw(context: context, canvasSize: size)
                    }
                    .gesture(DragGesture(minimumDistance: 0).onChanged({ drag in
                        game.onDrag(dragLocation: drag.location, screenSize: proxy.size)
                    }))
                }
                
                JoinToPlayView(gameState: game.gameState, action: { game.play() })
            }
            .background(Color.black)
            .task {
                await game.load()
            }
        }
    }
}
