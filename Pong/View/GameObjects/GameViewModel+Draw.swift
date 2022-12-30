//
//  GameViewModel+Draw.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import SwiftUI

private extension GameState {
    var drawBall: Bool {
        switch self {
        case .notReady(_), .ready:
            return false
        default:
            return true
        }
    }
}

extension GameViewModel {
    func draw(context: GraphicsContext, canvasSize: CGSize) {
        logic.draw(context: context, canvasSize: canvasSize, drawBall: gameState.drawBall)
    }
}

private extension GameLogic {
    func draw(context: GraphicsContext, canvasSize: CGSize, drawBall: Bool) {
        if drawBall { ball.draw(context: context, canvasSize: canvasSize, color: .white, path: .ball) }
        player.draw(context: context, canvasSize: canvasSize, color: .white, path: .paddle)
        opponent.draw(context: context, canvasSize: canvasSize, color: .white, path: .paddle)
    }
}
