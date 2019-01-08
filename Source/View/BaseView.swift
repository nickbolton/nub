//
//  BaseView.swift
//  Nub
//
//  Created by Nick Bolton on 8/2/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//

import UIKit

public protocol ThemeableView {
    func updateTheme()
    func setupTheme()
    var isThemeable: Bool { get }
}

open class BaseView: UIView, ThemeableView {
    
    private (set) public var didAddMissingConstraints = false
    private (set) public var didFinishInit = false
    private(set) public var isThemeable = false
    open var useSafeAreaContainer = false
    open var safeAreaContainerUsesStatusBarHeight = false
    
    private (set) public var safeAreaContainer = UIView()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    
    // MARK: Setup
    
    private func _commonInit() {
        initializeViews()
        assembleViews()
        constrainViews()
        setupTheme()
        didFinishInit = true
        didInit()
    }
    
    open func setupTheme() {
        isThemeable = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeChanged),
                                               name: NSNotification.Name.ThemeChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangePreferredContentSize),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    open func didInit() {
    }
    
    open func initializeViews() {
    }
    
    open func assembleViews() {
        if useSafeAreaContainer {
            addSubview(safeAreaContainer)
        }
    }
    
    open func constrainViews() {
    }
    
    private func constrainSafeAreaContainer() {
    }
    
    open func canAddMissingConstraints() -> Bool {
        return true
    }
    
    open func addMissingConstraints() {
        
    }
    
    private func _addMissingConstraintsIfNecessary() {
        if canAddMissingConstraints() && !didAddMissingConstraints {
            addMissingConstraints()
            didAddMissingConstraints = true
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _addMissingConstraintsIfNecessary()
        if useSafeAreaContainer {
            let topSpace = safeAreaContainerUsesStatusBarHeight ? statusBarHeight : safeRegionInsets.top
            safeAreaContainer.frame = CGRect(x: safeRegionInsets.left,
                                             y: topSpace,
                                             width: bounds.width - safeRegionInsets.left - safeRegionInsets.right,
                                             height: bounds.height - topSpace - safeRegionInsets.bottom)
        }
    }
    
    open override var frame: CGRect {
        didSet {
            _addMissingConstraintsIfNecessary()
        }
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
    
    // MARK: Theme
    
    open func updateTheme() {
        let subviews = self.subviews + safeAreaContainer.subviews
        for child in subviews {
            if let view = child as? ThemeableView, view.isThemeable {
                view.updateTheme()
            }
        }
    }
    
    open func preferredContentSizeChanged() {
    }
    
    open override func safeAreaInsetsDidChange() {
        if #available(iOS 11, *) {
            super.safeAreaInsetsDidChange()
        }
        updateSafeAreaConstraints()
    }
    
    open func updateSafeAreaConstraints() {
        guard useSafeAreaContainer else { return }
        setNeedsLayout()
    }
}
