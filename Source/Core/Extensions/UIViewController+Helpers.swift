//
//  UIViewController+Helpers.swift
//  Nub
//
//  Created by Nick Bolton on 7/14/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: Safe Area
    
    public var safeRegionInsets: UIEdgeInsets { return view.safeRegionInsets }

    public func wrapInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }

    @discardableResult
    public func presentViewControllerInNavigation(vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) -> UINavigationController {
        let nav = vc.wrapInNavigationController()
        present(nav, animated: animated, completion: completion)
        return nav
    }
    
    // MARK: Navigation
    
    public func navigateTo(vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }
}
