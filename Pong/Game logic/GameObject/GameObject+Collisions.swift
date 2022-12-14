//
//  GameObject+Collisions.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 12/12/22.
//

import Foundation

extension GameObject {
    func collides(with gameObject: GameObject, screenRatio: CGFloat) -> Bool {
        return frame(screenRatio).intersects(gameObject.frame(screenRatio))
    }
}
