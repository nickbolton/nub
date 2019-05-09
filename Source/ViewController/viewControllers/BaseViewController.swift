//
//  BaseViewController.swift
//  Nub
//
//  Created by Nick Bolton on 7/13/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//

import UIKit
import Reachability

protocol Transparentable {
    var isBackgroundTransparent: Bool { get set }
}

public protocol StatusBarManaging {
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var prefersStatusBarHidden: Bool { get }
    var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { get }

}

open class BaseViewController<T:UIView>: UIViewController, StatusBarManaging, DispatchTaskPerformer {

    private(set) public var firstAppearance = true
    private(set) public var appearanceCount = 0
    private(set) public var hasAppeared = false
    private(set) public var isAppearing = false
    private(set) public var isThemeable = false
    public var shouldMonitoringReachability = false
    
    public var theme: Theme?
    
    private var currentTheme: Theme { return theme ?? ThemeManager.shared.currentTheme() }

    public var isBackgroundTransparent = false { didSet { updateTheme() } }
    let upVerticalSwipe = UISwipeGestureRecognizer(target: nil, action: nil)
    let downVerticalSwipe = UISwipeGestureRecognizer(target: nil, action: nil)
    public var isThemeGesturesEnabled = true {
        didSet {
            if isThemeGesturesEnabled {
                upVerticalSwipe.isEnabled = true
                upVerticalSwipe.isEnabled = true
                view.addGestureRecognizer(upVerticalSwipe)
                view.addGestureRecognizer(downVerticalSwipe)
            } else {
                upVerticalSwipe.isEnabled = false
                upVerticalSwipe.isEnabled = false
                view.removeGestureRecognizer(upVerticalSwipe)
                view.removeGestureRecognizer(downVerticalSwipe)
            }
        }
    }

    public var rootView: T { return view as! T }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Setup
    
    open func setupTheme() {
        
        isThemeable = true
        
        // two finger up swipe
        upVerticalSwipe.addTarget(self, action: #selector(handleUpVerticalSwipe))
        upVerticalSwipe.direction = .up
        upVerticalSwipe.numberOfTouchesRequired = 2
        view.addGestureRecognizer(upVerticalSwipe)
        
        // two finger down swipe
        downVerticalSwipe.addTarget(self, action: #selector(handleDownVerticalSwipe))
        downVerticalSwipe.direction = .down
        downVerticalSwipe.numberOfTouchesRequired = 2
        view.addGestureRecognizer(downVerticalSwipe)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeChanged),
                                               name: NSNotification.Name.ThemeChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangePreferredContentSize),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        
        (view as? ThemeableView)?.setupTheme()
    }
    
    // MARK: View Lifecycle
    
    open override func loadView() {
        view = T()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        if isThemeable {
            updateTheme()
        }
        if shouldMonitoringReachability {
            startReachability()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        appearanceCount += 1
        isAppearing = true
        firstAppearance = (appearanceCount == 1);
        super.viewDidAppear(animated)
        hasAppeared = true
        if isThemeable {
            updateTheme()
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppearing = false
        stopReachability()
    }
    
    // MARK: Gestures
    
    @objc internal func handleUpVerticalSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            let name = ThemeManager.defaultLightThemeName
            LockerManager.shared.defaultLocker.themeName = name
            ThemeManager.shared.selectThemeNamed(name)
        }
    }
    
    @objc internal func handleDownVerticalSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            let name = ThemeManager.defaultDarkThemeName
            LockerManager.shared.defaultLocker.themeName = name
            ThemeManager.shared.selectThemeNamed(name)
        }
    }
    
    // MARK: Status Bar
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return isThemeable ? currentTheme.statusBarStyle : statusBarStyle
    }
    
    private var _isStatusBarHidden = false
    public var isStatusBarHidden: Bool {
        get {
            let result = isThemeable ? currentTheme.isStatusBarHidden : _isStatusBarHidden
            return result
        }
        set {
            _isStatusBarHidden = newValue
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    public var statusBarStyle = UIStatusBarStyle.lightContent
    public var statusBarAnimation = UIStatusBarAnimation.fade
    override open var prefersStatusBarHidden: Bool { return isStatusBarHidden }
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return statusBarAnimation }
    
    // MARK: Theme
    
    open func updateTheme() {
        guard isThemeable else { return }
        if let view = rootView as? ThemeableView, view.isThemeable {
            view.updateTheme()
        }
        if isBackgroundTransparent {
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = currentTheme.defaultBackgroundColor
        }
        view.window?.backgroundColor = view.backgroundColor
        setNeedsStatusBarAppearanceUpdate()
    }
    
    open func preferredContentSizeChanged() {
    }
    
    public func transitionTheme() {
        guard isThemeable else { return }
        if ThemeManager.shared.selectedName != LockerManager.shared.defaultLocker.themeName {
            let options = UIView.AnimationOptions.curveEaseInOut
              .union(.beginFromCurrentState)
              .union(.allowAnimatedContent)
              .union(.transitionCrossDissolve)
            UIView.transition(with: view, duration: currentTheme.defaultAnimationDuration, options: options, animations: {
                ThemeManager.shared.selectThemeNamed(LockerManager.shared.defaultLocker.themeName)
            })
        }
    }
    
    // MARK: Reachability
    
    private (set) public var reachability = Reachability()
    
    public func startReachability() {
        do {
            try reachability?.startNotifier()
            reachability?.whenReachable = { [weak self] reachability in
                DispatchQueue.main.async { self?.reachabilityStatusChanged(reachability) }
            }
            reachability?.whenUnreachable = { [weak self] reachability in
                DispatchQueue.main.async { self?.reachabilityStatusChanged(reachability) }
            }
        } catch {
            Logger.shared.error("\(error)")
        }
    }
    
    public func stopReachability() {
        reachability?.stopNotifier()
        reachability?.whenUnreachable = nil
        reachability?.whenReachable = nil
    }
    
    open func reachabilityStatusChanged(_ reachability: Reachability) {
    }
    
    // MARK: Notifications
    
    @objc internal func themeChanged() {
        updateTheme()
    }
    
    @objc internal func didChangePreferredContentSize(_ noti: Notification) {
        if let setting = noti.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as? UIContentSizeCategory {
            ThemeManager.shared.contentSizeCategory = setting
        }
        preferredContentSizeChanged()
    }
    
    public func observeApplicationWillEnterForeground() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground(noti:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    public func unobserveApplicationWillEnterForeground() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
    }
    
    public func observeApplicationDidEnterBackground() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(noti:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    public func unobserveApplicationDidEnterBackground() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
    }
    
    public func observeApplicationWillResignActive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive(noti:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    public func unobserveApplicationWillResignActive() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willResignActiveNotification,
                                                  object: nil)
    }
    
    public func observeApplicationDidBecomeActive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive(noti:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    public func unobserveApplicationDidBecomeActive() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    public func observeApplicationWillTerminate() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillTerminate(noti:)),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }
    
    public func unobserveApplicationWillTerminate() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willTerminateNotification,
                                                  object: nil)
    }
    
    public func observeKeyboardWillHide() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(noti:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    public func unobserveKeyboardWillHide() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    public func observeKeyboardWillShow() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(noti:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    public func unobserveKeyboardWillShow() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
    }
    
    @objc open func applicationWillEnterForeground(noti: NSNotification) {
        if shouldMonitoringReachability {
            startReachability()
        }
    }
    
    @objc open func applicationDidEnterBackground(noti: NSNotification) {
        stopReachability()
    }
    
    @objc open func applicationWillResignActive(noti: NSNotification) {
        
    }
    
    @objc open func applicationDidBecomeActive(noti: NSNotification) {
        
    }
    
    @objc open func applicationWillTerminate(noti: NSNotification) {
        
    }
    
    @objc open func keyboardWillShow(noti: NSNotification) {
        
        guard let userInfo = noti.userInfo else {
            return
        }
        
        guard let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        guard let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let translation = -frameValue.cgRectValue.height
        let curve = UIView.AnimationOptions(rawValue: curveValue)
        
        keyboardWillShow(userInfo: userInfo, curve: curve, duration: duration, translation: translation)
    }
    
    @objc open func keyboardWillHide(noti: NSNotification) {
        
        if isAppearing {
            
            guard let userInfo = noti.userInfo else {
                return
            }
            
            guard let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return
            }
            
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return
            }
            
            guard let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            
            let curve = UIView.AnimationOptions(rawValue: curveValue)
            let translation = frameValue.cgRectValue.height

            keyboardWillHide(userInfo: userInfo, curve: curve, duration: duration, translation: translation)
        }        
    }
    
    open func keyboardWillShow(userInfo: [AnyHashable : Any]?, curve: UIView.AnimationOptions, duration: TimeInterval, translation: CGFloat) {
        // abstract
    }
    
    open func keyboardWillHide(userInfo: [AnyHashable : Any]?, curve: UIView.AnimationOptions, duration: TimeInterval, translation: CGFloat) {
        // abstract
    }
}
