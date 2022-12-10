//
//  GameObject.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 10/12/22.
//

import Foundation

protocol GameObject {
    var position: CGPoint {get set}
    var velocity: CGPoint {get set}
    var width: CGFloat {get}
    var aspectRatio: CGFloat {get}
}

extension GameObject {
    var height: CGFloat {
        width * aspectRatio
    }
}
