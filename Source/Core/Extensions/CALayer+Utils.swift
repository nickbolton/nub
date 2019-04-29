//
//  CALayer+Utils.swift
//  Nub
//
//  Created by Nick Bolton on 2/1/19.
//

import UIKit

public struct SketchShadow {
    public let color: UIColor
    public let opacity: Float
    public let x: CGFloat
    public let y: CGFloat
    public let blur: CGFloat
    public let spread: CGFloat
    
    public init(color: UIColor = .black,
                opacity: Float = 0.5,
                x: CGFloat = 0,
                y: CGFloat = 2,
                blur: CGFloat = 4,
                spread: CGFloat = 0) {
        self.color = color
        self.opacity = opacity
        self.x = x
        self.y = y
        self.blur = blur
        self.spread = spread
    }
}

public extension CALayer {
    
    public func apply(sketchShadow: SketchShadow) {
        applySketchShadow(color: sketchShadow.color,
                          opacity: sketchShadow.opacity,
                          x: sketchShadow.x,
                          y: sketchShadow.y,
                          blur: sketchShadow.blur,
                          spread: sketchShadow.spread)
    }
    
    public func applySketchShadow(
        color: UIColor = .black,
        opacity: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
