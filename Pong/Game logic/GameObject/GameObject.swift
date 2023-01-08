//
//  GameObject.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation

enum Anchor {
    case center
    case centerTop
    case centerBottom
}

extension GameObject {
    static var ball: GameObject {
        .init(position: .init(x: 0.5, y: 0.1), width: 0.05, aspectRatio: 1.0, velocity: .zero)
    }
    
    static func paddle(_ isPlayer: Bool, anchor: Anchor) -> GameObject {
        let width: CGFloat = 0.24
        let y: CGFloat = isPlayer ? 0.9 : 0.1
        return .init(position: .init(x: 0.5, y: y), width: width, aspectRatio: 0.2, velocity: .zero, anchor: anchor)
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
    var anchor: Anchor
    private let heightValue: GameObjectHeightValue
    private var prevPosition: CGPoint
    
    init(position: CGPoint, width: CGFloat, aspectRatio: CGFloat, velocity: CGPoint, anchor: Anchor = .center) {
        self.position = position
        self.width = width
        self.velocity = velocity
        self.heightValue = .relativeToWidth(aspectRatio: aspectRatio)
        self.prevPosition = position
        self.anchor = anchor
    }
    
    init(position: CGPoint, width: CGFloat, height: CGFloat, velocity: CGPoint, anchor: Anchor = .center) {
        self.position = position
        self.width = width
        self.velocity = velocity
        self.heightValue = .relativeToContainerHeight(height: height)
        self.prevPosition = position
        self.anchor = anchor
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
        var y = position.y
        
        switch anchor {
        case .center:
            y -= height(screenRatio) * 0.5
        case .centerTop:
            break
        case .centerBottom:
            y -= height(screenRatio)
        }
        
        return .init(origin: .init(x: (position.x - width * 0.5), y: y), size: .init(width: width, height: height(screenRatio)))
    }
}
