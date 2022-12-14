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
        
        static let block: ObjectPath = .init { rect in
            Path(roundedRect: rect, cornerRadius: 0)
        }
    }
    
    private func rectInCanvas(_ canvasSize: CGSize) -> CGRect {
        let screenRatio: CGFloat = canvasSize.width / canvasSize.height
        let frame = frame(screenRatio)
        return CGRect(origin: CGPoint(x: frame.origin.x * canvasSize.width, y: frame.origin.y  * canvasSize.height), size: CGSize(width: frame.size.width * canvasSize.width, height: frame.size.height * canvasSize.height))
    }
    
    func draw(context: GraphicsContext, canvasSize: CGSize, color: Color, path: ObjectPath) {
        let objectPath = path.build(rectInCanvas(canvasSize))
        context.fill(objectPath, with: .color(color))
    }
}
