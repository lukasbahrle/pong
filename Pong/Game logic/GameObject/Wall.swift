//
//  Wall.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 13/12/22.
//

import Foundation

enum Wall {
    enum Alignment {
        case left
        case top
        case right
        case bottom
        
        func position(_ gameObject: GameObject) -> CGPoint {
            switch self {
            case .left:
                return .init(x: -gameObject.width * 0.5, y: 0.5)
            case .top:
                return .init(x: 0.5, y: -gameObject.height() * 0.5)
            case .right:
                return .init(x: 1 + gameObject.width * 0.5, y: 0.5)
            case .bottom:
                return .init(x: 0.5, y: 1 + gameObject.height() * 0.5)
            }
        }
    }
}
