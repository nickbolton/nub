//
//  UINavigationController+Helpers.swift
//  Nub
//
//  Created by Nick Bolton on 8/17/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//
import UIKit

extension UINavigationController {
    public func makeNavBarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
}
