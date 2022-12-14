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
        return .init(position: .init(x: 0.5, y: y), width: width, aspectRatio: 0.2, velocity: .zero)
    }
    
    static func wall(_ alignment: Wall.Alignment) -> GameObject {
        let gameObject = GameObject(position: .zero, width: 1.0, height: 1.0, velocity: .zero)
        gameObject.position = alignment.position(gameObject)
        return gameObject
    }
}

enum GameObjectHeightValue {
    case relativeToContainerHeight(height: CGFloat)
    case relativeToWidth(aspectRatio: CGFloat)
    
    var value: CGFloat {
        switch self {
        case let .relativeToContainerHeight(value):
            return value
        case let .relativeToWidth(value):
            return value
        }
    }
}

class GameObject {
    var position: CGPoint
    var velocity: CGPoint
    var width: CGFloat
    private let heightValue: GameObjectHeightValue
    private var prevPosition: CGPoint
    
    init(position: CGPoint, width: CGFloat, aspectRatio: CGFloat, velocity: CGPoint) {
        self.position = position
        self.width = width
        self.velocity = velocity
        self.heightValue = .relativeToWidth(aspectRatio: aspectRatio)
        self.prevPosition = position
    }
    
    init(position: CGPoint, width: CGFloat, height: CGFloat, velocity: CGPoint) {
        self.position = position
        self.width = width
        self.velocity = velocity
        self.heightValue = .relativeToContainerHeight(height: height)
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
    func height(_ screenRatio: CGFloat = 0) -> CGFloat {
        switch heightValue {
        case .relativeToContainerHeight(height: let height):
            return height
        case .relativeToWidth(aspectRatio: let aspectRatio):
            return aspectRatio * width * screenRatio
        }
    }
    
    func frame(_ screenRatio: CGFloat) -> CGRect {
        .init(origin: .init(x: (position.x - width * 0.5), y: position.y - height(screenRatio) * 0.5), size: .init(width: width, height: height(screenRatio)))
    }
}
