//
//  PongApp.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 9/12/22.
//

import SwiftUI

@main
struct PongApp: App {
    private enum GameMode {
        case groupActivity
        case groupActivityTest
        case local
    }
    
    private let mode: GameMode = .groupActivity
    
    var body: some Scene {
        WindowGroup {
            switch mode {
            case .groupActivity:
                GameView(game: Factory.groupActivity())
            case .groupActivityTest:
                let (local, remote) = Factory.groupActivityTest()
                GameViewGroupActivityTest(local: local, remote: remote)
            case .local:
                GameView(game: Factory.local())
            }
        }
    }
}
