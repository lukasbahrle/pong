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
    
    init(position: CGPoint, width: CGFloat, aspectRatio: CGFloat, velocity: CGPoint) {
        self.position = position
        self.width = width
        self.velocity = velocity
        self.aspectRatio = aspectRatio
    }
}

extension GameObject {
    var height: CGFloat {
        width * aspectRatio
    }
}