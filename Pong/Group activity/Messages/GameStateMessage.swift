//
//  GameStateMessage.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 1/1/23.
//

import Foundation

struct GameStateMessage: Codable {
    let score: [UUID: Int]
    let state: GameState
}
