//
//  CGPoint+Arithmetic.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import Foundation

extension CGPoint {
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
      return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func -= (left: inout CGPoint, right: CGPoint) {
      left = left - right
    }
    
    static func / (left: CGPoint, value: TimeInterval) -> CGPoint {
      return CGPoint(x: left.x / value, y: left.y / value)
    }
    
    
    static func * (left: CGPoint, value: CGFloat) -> CGPoint {
      return CGPoint(x: left.x * value, y: left.y * value)
    }
    
    static func *= (left: inout CGPoint, value: CGFloat) {
      left = left * value
    }
    
    static func - (left: Double, right: CGPoint) -> CGPoint {
      return CGPoint(x: left - right.x, y: left - right.y)
    }
}
