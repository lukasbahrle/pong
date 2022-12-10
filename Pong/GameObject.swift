//
//  GameObject.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation


extension GameObject {
    static func ball(position: CGPoint, width: CGFloat, velocity: CGPoint)  -> GameObject {
        .init(position: position, width: width, aspectRatio: 1.0, velocity: velocity)
    }
    
    static func paddle(position: CGPoint, width: CGFloat, velocity: CGPoint)  -> GameObject {
        .init(position: position, width: width, aspectRatio: 0.2, velocity: velocity)
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
