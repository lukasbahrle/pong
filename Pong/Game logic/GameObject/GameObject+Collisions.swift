//
//  GameObject+Collisions.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 12/12/22.
//

import Foundation

extension GameObject {
    func collides(with gameObject: GameObject, screenSize: CGSize) -> Bool {
        return frame(screenSize).intersects(gameObject.frame(screenSize))
    }
}
