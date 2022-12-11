//
//  GameObject.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation

extension GameObject {
    static var ball: GameObject {
        .init(position: .init(x: 0.5, y: 0.5), width: 0.05, aspectRatio: 1.0, velocity: .zero)
    }
    
    static func paddle(_ isPlayer: Bool) -> GameObject {
        let width: CGFloat = 0.24
        let y: CGFloat = isPlayer ? 0.9 : 0.1
        return .init(position: .init(x: 0.5 - width * 0.5, y: y), width: width, aspectRatio: 0.2, velocity: .zero)
    }
}

class GameObject {
    var position: CGPoint
    var velocity: CGPoint
    var width: CGFloat
    var aspectRatio: CGFloat
    private var prevPosition: CGPoint
    
    init(position: CGPoint, width: CGFloat, aspectRatio: CGFloat, velocity: CGPoint) {
        self.position = position
        self.width = width
        self.velocity = velocity
        self.aspectRatio = aspectRatio
        self.prevPosition = position
    }
    
    func update(deltaTime: TimeInterval, move: Bool = true) {
        if move {
            let dx = velocity.x * deltaTime
            let dy = velocity.y * deltaTime
            position = .init(x: position.x + dx, y: position.y + dy)
        }
        else {
            let distance = position - prevPosition
           velocity = distance / deltaTime
        }
        
        self.prevPosition = position
    }
}

extension GameObject {
    var height: CGFloat {
        width * aspectRatio
    }
}
