//
//  ContentView.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 9/12/22.
//

import SwiftUI

struct TestLocalAndRemoteView: View {
    let local: GameViewModel
    let remote: GameViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            GameView(game: local)
            GameView(game: remote)
                .padding(.horizontal, 250)
        }
        .background(Color.gray)
    }
}
