//
//  ThemedNavigationController.swift
//  Nub
//
//  Created by Nick Bolton on 4/7/18.
//

import UIKit

open class ThemedNavigationController: UINavigationController {

    // MARK: Status Bar
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let current = viewControllers.last as? BaseViewController {
            return current.preferredStatusBarStyle
        }
        return statusBarStyle
    }

    override open var prefersStatusBarHidden: Bool {
        if let current = viewControllers.last as? BaseViewController {
            return current.prefersStatusBarHidden
        }
        return isStatusBarHidden
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let current = viewControllers.last as? BaseViewController {
            return current.preferredStatusBarUpdateAnimation
        }
        return statusBarAnimation
    }

    public var isStatusBarHidden = false { didSet { setNeedsStatusBarAppearanceUpdate() } }
    public var statusBarStyle = UIStatusBarStyle.lightContent
    public var statusBarAnimation = UIStatusBarAnimation.fade
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        super.pushViewController(viewController, animated: true)
    }
}
