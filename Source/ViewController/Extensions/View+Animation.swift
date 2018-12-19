//
//  View+Animation.swift
//  Nub
//
//  Created by Nick Bolton on 8/17/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//
import UIKit

extension UIView {
    
    static public let defaultAnimationOptions = UIView.AnimationOptions.curveEaseInOut.union(.beginFromCurrentState).union(.allowAnimatedContent)
    
    static public let defaultTransitionOptions = UIView.AnimationOptions.curveEaseInOut.union(.beginFromCurrentState).union(.allowAnimatedContent).union(.transitionCrossDissolve)
    
    public func convertCenter(to: UIView!) -> CGPoint {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return convert(center, to: to)
    }
}
