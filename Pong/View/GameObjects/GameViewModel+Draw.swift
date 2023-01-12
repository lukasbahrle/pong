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
        gameOutput.draw(context: context, canvasSize: canvasSize, drawBall: gameState.drawBall)
    }
}

private extension GameOutput {
    func draw(context: GraphicsContext, canvasSize: CGSize, drawBall: Bool) {
        player.draw(context: context, canvasSize: canvasSize, color: .white, path: .paddle)
        opponent.draw(context: context, canvasSize: canvasSize, color: .white, path: .paddle)
        if drawBall { ball.draw(context: context, canvasSize: canvasSize, color: .blue, path: .ball) }
    }
}
