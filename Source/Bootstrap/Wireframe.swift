//
//  Wireframe.swift
//  SimpleTweet
//
//  Created by Nick Bolton on 8/2/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit
import SafariServices

public class WireframeManager: NSObject {
    static private (set) public var shared = WireframeManager()
    private override init() {}
    
    private (set) public var wireframe = Wireframe()
    
    public func registerWireframe(_ wireframe: Wireframe) {
        self.wireframe = wireframe
    }
}

open class Wireframe: NSObject, SFSafariViewControllerDelegate {

    private var mainWindow: UIWindow?
    private var modalWindow: UIWindow?
    private weak var lastPresentedViewController: UIViewController?
    private var safariViewController: SFSafariViewController?

    open func wireApplication(window: UIWindow) {
        mainWindow = window
    }
    
    public func openURLInSafariViewController(_ url: URL, from: UIViewController) {
        guard safariViewController == nil else { return }
        let vc = SFSafariViewController(url: url)
        vc.delegate = self
        safariViewController = vc
        presentViewController(vc, from: from)
    }
    
    public func dismissSafariViewController() {
        guard safariViewController != nil else { return }
        dismissViewController(vc: safariViewController)
        safariViewController = nil
    }
    
    public func presentViewController(_ vc: UIViewController,
                               from: UIViewController,
                               wrapInNav: Bool = false,
                               animated: Bool = true,
                               completion: (()->Void)? = nil) {
        let targetVC = wrapInNav ? UINavigationController(rootViewController: vc) : vc
        lastPresentedViewController = vc
        from.present(targetVC, animated: animated, completion: completion)
    }
        
    public func dismissViewController(vc: UIViewController?, animated: Bool = true, completion: (()->Void)? = nil) {
        guard let vc = vc else { return }
        let target = vc.navigationController != nil ? vc.navigationController! : vc
        target.dismiss(animated: animated, completion: completion)
    }
    
    public func presentModalWindow(withVC: UIViewController, windowLevel: UIWindow.Level = UIWindow.Level.statusBar - 1, animated: Bool = true, animations: (()->Void)? = nil, completion: (()->Void)? = nil) {
        
        if self.modalWindow != nil {
            return
        }
        
        let window = UIWindow()
        window.frame = mainWindow!.frame
        window.windowLevel = windowLevel
        window.alpha = 0.0
        window.rootViewController = withVC
        window.makeKeyAndVisible()
        self.modalWindow = window
        
        let duration: TimeInterval = animated ? ThemeManager.shared.currentTheme().defaultAnimationDuration : 0.0
        UIView.animate(withDuration: duration, animations:
            {
                window.alpha = 1.0
                animations?()
            }, completion: { (value: Bool) in
                if let completion = completion {
                    completion()
                }
        })
    }
    
    public func dismissModalWindow(animated: Bool = true, animations: (()->Void)? = nil, completion: (()->Void)? = nil) {
     
        guard let window = modalWindow else {
            completion?()
            return
        }
        
        let duration: TimeInterval = animated ? ThemeManager.shared.currentTheme().defaultAnimationDuration : 0.0
        UIView.animate(withDuration: duration, animations:
            {
                window.alpha = 0.0
                animations?()
            }, completion: { (value: Bool) in
                self.mainWindow!.makeKeyAndVisible()
                window.rootViewController = nil
                self.modalWindow = nil
                completion?()
        })
    }
    
    // MARK: SFSafariViewControllerDelegate Conformance
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismissSafariViewController()
    }
}
