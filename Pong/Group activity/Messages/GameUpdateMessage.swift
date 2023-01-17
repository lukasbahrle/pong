//
//  GameUpdateMessage.swift
//  Pong
//
//  Created by Bahrle, Lukas on 17/1/23.
//

import Foundation

struct GameUpdateMessage: Codable {
    struct Ball: Codable {
        let position: CGPoint
        let velocity: CGPoint
    }
    let player: UUID
    let playerPaddle: CGFloat
    let ball: Ball
}
