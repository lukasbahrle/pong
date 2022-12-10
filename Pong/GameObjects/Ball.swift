//
//  Ball.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation

class Ball: GameObject {
    var position: CGPoint
    var velocity: CGPoint
    var width: CGFloat
    var aspectRatio: CGFloat = 1.0
    
    init(position: CGPoint, width: CGFloat, velocity: CGPoint) {
        self.position = position
        self.width = width
        self.velocity = velocity
    }
}
