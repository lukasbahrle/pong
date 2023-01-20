//
//  PongApp.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 9/12/22.
//

import SwiftUI

@main
struct PongApp: App {
    private let test = false
    
    var body: some Scene {
        WindowGroup {
            if test {
                let (local, remote) = Factory.groupActivityTest()
                GameViewGroupActivityTest(local: local, remote: remote)
            }
            else {
                GameView(game: Factory.groupActivity())
            }
        }
    }
}


