//
//  GameViewModel+Draw.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import SwiftUI

extension GameViewModel {
    func draw(context: GraphicsContext, canvasSize: CGSize) {
        logic.draw(context: context, canvasSize: canvasSize)
    }
}

private extension GameLogic {
    func draw(context: GraphicsContext, canvasSize: CGSize) {
        ball.draw(context: context, canvasSize: canvasSize, color: .white, path: .ball)
        player.draw(context: context, canvasSize: canvasSize, color: .white, path: .paddle)
        opponent.draw(context: context, canvasSize: canvasSize, color: .white, path: .paddle)
    }
}