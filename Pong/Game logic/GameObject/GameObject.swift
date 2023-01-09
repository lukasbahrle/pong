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
        .init(position: .init(x: 0.5, y: 0.1), width: .fixed(20), aspectRatio: 1.0, velocity: .zero)
    }
    
    static func paddle(_ isPlayer: Bool, anchor: Anchor) -> GameObject {
        let width: CGFloat = 0.24
        let y: CGFloat = isPlayer ? 0.9 : 0.1
        return .init(position: .init(x: 0.5, y: y), width: .relativeToContainerWidth(width), height: .fixed(20), velocity: .zero, anchor: anchor)
    }
    
    static func wall(_ alignment: Wall.Alignment) -> GameObject {
        let gameObject = GameObject(position: .zero, width: .relativeToContainerWidth(1.0), height: .relativeToContainerHeight(1.0), velocity: .zero)
        gameObject.position = alignment.position(gameObject)
        return gameObject
    }
}

enum SizeDimension {
    enum Width {
        case relativeToContainerWidth(CGFloat)
        case fixed(CGFloat)
    }
    
    enum Height {
        case relativeToContainerHeight(CGFloat)
        case relativeToWidth(CGFloat)
        case fixed(CGFloat)
    }
}

class GameObject {
    var position: CGPoint
    var velocity: CGPoint
    var anchor: Anchor
    private let widthValue: SizeDimension.Width
    private let heightValue: SizeDimension.Height
    private var prevPosition: CGPoint
    
    init(position: CGPoint, width: SizeDimension.Width, aspectRatio: CGFloat, velocity: CGPoint, anchor: Anchor = .center) {
        self.position = position
        self.widthValue = width
        self.velocity = velocity
        self.heightValue = .relativeToWidth(aspectRatio)
        self.prevPosition = position
        self.anchor = anchor
    }
    
    init(position: CGPoint, width: SizeDimension.Width, height: SizeDimension.Height, velocity: CGPoint, anchor: Anchor = .center) {
        self.position = position
        self.widthValue = width
        self.velocity = velocity
        self.heightValue = height
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
    func height(_ screenSize: CGSize = .zero) -> CGFloat {
        let screenRatio = screenSize.width / screenSize.height
        
        switch heightValue {
        case .relativeToContainerHeight(let value):
            return value
        case .relativeToWidth(let aspectRatio):
            return aspectRatio * width(screenSize) * screenRatio
        case .fixed(let value):
            return value / screenSize.height
        }
    }
    
    func width(_ screenSize: CGSize = .zero) -> CGFloat {
        switch widthValue {
        case .fixed(let value):
            return value / screenSize.width
        case .relativeToContainerWidth(let value):
            return value
        }
    }
    
    func frame(_ screenSize: CGSize) -> CGRect {
        var y = position.y
        
        switch anchor {
        case .center:
            y -= height(screenSize) * 0.5
        case .centerTop:
            break
        case .centerBottom:
            y -= height(screenSize)
        }
        
        return .init(origin: .init(x: (position.x - width(screenSize) * 0.5), y: y), size: .init(width: width(screenSize), height: height(screenSize)))
    }
}
