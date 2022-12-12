//
//  GameObject+Collisions.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 12/12/22.
//

import Foundation

extension GameObject {
    func collides(with gameObject: GameObject, screenRatio: CGFloat) -> Bool {
        CGRect(origin: position, size: .init(width: width, height: height * screenRatio)).intersects(.init(origin: gameObject.position, size: .init(width: gameObject.width, height: gameObject.height * screenRatio)))
    }
}
