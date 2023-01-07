//
//  SimpleGameController.swift
//  Pong
//
//  Created by Bahrle, Lukas on 5/1/23.
//

import Foundation
import Combine

class SimpleGameController: GameController {
    var movePlayerPublisher: AnyPublisher<CGFloat, Never> {
        movePlayerSubject.eraseToAnyPublisher()
    }
    private let movePlayerSubject = PassthroughSubject<CGFloat, Never>()
    
    var moveOpponentPublisher: AnyPublisher<CGFloat, Never> {
        moveOpponentSubject.eraseToAnyPublisher()
    }
    private let moveOpponentSubject = PassthroughSubject<CGFloat, Never>()
    
    func load() async {}
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        let y = dragLocation.y / screenSize.height
        
        if y < 0.5 {
            moveOpponentSubject.send(dragLocation.x / screenSize.width)
        }
        else {
            movePlayerSubject.send(dragLocation.x / screenSize.width)
        }
    }
}
