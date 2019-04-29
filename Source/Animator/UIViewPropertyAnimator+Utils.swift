//
//  UIViewPropertyAnimator+Utils.swift
//  Nub
//
//  Created by Nick Bolton on 4/9/19.
//

import UIKit

extension UIViewPropertyAnimator {
    
    @discardableResult
    open class func runningPropertyAnimator(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, easing: Easing = Easing(.quadInOut), animations: @escaping () -> Void, completion: ((UIViewAnimatingPosition) -> Void)? = nil) -> UIViewPropertyAnimator {
     
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: easing)
        animator.addAnimations(animations)
        animator.addCompletion { pos in
            completion?(pos)
        }
        animator.startAnimation(afterDelay: delay)
        return animator
    }
}
