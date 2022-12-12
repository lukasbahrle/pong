//
//  ContentView.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 9/12/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game = GameViewModel()
    
    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    game.update(timestamp: timeline.date.timeIntervalSinceReferenceDate, screenRatio: size.width/size.height)
                    
                    context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color.black))
                    
                    game.draw(context: context, canvasSize: size)
                }
                .gesture(DragGesture(minimumDistance: 0).onChanged({ drag in
                    game.onDrag(dragLocation: drag.location, screenSize: UIScreen.main.bounds.size)
                }))
            }
            
            if game.gameState == .readyToPlay || game.gameState == .gameOver {
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
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
