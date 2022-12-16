//
//  ContentView.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 9/12/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game = GameViewModel()
    
    private var scoreOpacity: Double {
        switch game.gameState {
        case .readyToPlay:
            return 0
        case .playing:
            return 0.2
        case .goal:
            return 1.0
        case .gameOver:
            return 1.0
        }
    }
    
    private var linesOpacity: Double {
        switch game.gameState {
        case .readyToPlay:
            return 0
        case .playing:
            return 0.2
        case .goal:
            return 0
        case .gameOver:
            return 0
        }
    }
    
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
                .overlay(.white.opacity(linesOpacity))
            
            Circle()
                .strokeBorder(.white.opacity(linesOpacity),lineWidth: 2)
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
            
            if game.gameState == .readyToPlay {
                Button {
                    game.play()
                } label: {
                    Text("Play")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule())
                }
            }
        }
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
