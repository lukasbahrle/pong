//
//  JoinToPlayView.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 30/12/22.
//

import SwiftUI
import GroupActivities

struct JoinToPlayView: View {
    let gameState: GameState
    let action: () -> Void
    @StateObject private var groupStateObserver = GroupStateObserver()
    @State private var isDisplayingSharingController: Bool = false
    
    var body: some View {
        VStack {
            if gameState == .ready {
                Button {
                    action()
                } label: {
                    Text("Play")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule())
                }
            }
            else if case let .notReady(playerType) = gameState {
                
                if playerType == .opponent {
                    Label("Waiting for your opponent to join", systemImage: "person.badge.clock.fill")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.9))
                        .background(Color.black)
                }
                else {
                    Button {
                        if groupStateObserver.isEligibleForGroupSession {
                            action()
                        }
                        else {
                            isDisplayingSharingController = true
                        }
                    } label: {
                        Label("Join to play", systemImage: "person.2.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule())
                    }
                    .sheet(isPresented: $isDisplayingSharingController) {
                        ActivitySharingViewController()
                    }
                }
            }
        }
    }
}
