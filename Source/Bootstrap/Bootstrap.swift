//
//  Bootstrap.swift
//  Nub
//
//  Created by Nick Bolton on 8/2/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class Bootstrap: NSObject {
    
    public struct Result {
        private(set) public var ok: Bool = true
        private(set) public var window: UIWindow
        
        init(window: UIWindow) {
            self.window = window
        }
    }

    open func initialize(app: UIApplication,
                         launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Result {
        if !LockerManager.shared.defaultLocker.hasLaunchedApp {
            LockerManager.shared.wipeData()
            LockerManager.shared.defaultLocker.hasLaunchedApp = true
        }
        let window = setupWindow()
        WireframeManager.shared.wireframe.wireApplication(window: window);
        window.makeKeyAndVisible()
        return Result(window: window)
    }
    
    open func setupWindow() -> UIWindow {
        let frame = UIScreen.main.bounds
        return UIWindow(frame: frame)
    }
}
