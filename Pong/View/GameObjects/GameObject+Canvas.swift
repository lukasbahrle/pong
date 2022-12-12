//
//  GameObject+Canvas.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import SwiftUI

extension GameObject {
    struct ObjectPath {
        let build: (CGRect) -> Path
        
        static let ball: ObjectPath = .init { rect in
            Path(ellipseIn: rect)
        }
        
        static let paddle: ObjectPath = .init { rect in
            Path(roundedRect: rect, cornerRadius: 10)
        }
    }
    
    private func rectInCanvas(_ canvasSize: CGSize) -> CGRect {
        .init(origin: .init(x: (position.x - width * 0.5) * canvasSize.width, y: position.y  * canvasSize.height - height * canvasSize.width * 0.5), size: .init(width: width * canvasSize.width, height: height * canvasSize.width))
    }
    
    func draw(context: GraphicsContext, canvasSize: CGSize, color: Color, path: ObjectPath) {
        let objectPath = path.build(rectInCanvas(canvasSize))
        context.fill(objectPath, with: .color(color))
    }
}
