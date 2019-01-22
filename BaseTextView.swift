//
//  BaseTextView.swift
//  Nub
//
//  Created by Nick Bolton on 1/20/19.
//

import UIKit

class BaseTextView: UITextView {

    private var didAddMissingConstraints = false;
    private(set) public var isThemeable = false
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        _commonInit()
    }
        
    // MARK: Setup
    
    private func _commonInit() {
        initializeViews()
        assembleViews()
        constrainViews()
        setupTheme()
        didInit()
    }
    
    open func didInit() {
    }
    
    open func initializeViews() {
    }
    
    open func assembleViews() {
    }
    
    open func constrainViews() {
    }
    
    open func canAddMissingConstraints() -> Bool {
        return true
    }
    
    open func addMissingConstraints() {
    }
    
    func _addMissingConstraintsIfNecessary() {
        if canAddMissingConstraints() && !didAddMissingConstraints {
            didAddMissingConstraints = true;
            addMissingConstraints()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _addMissingConstraintsIfNecessary()
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
    
    // MARK: Theme
    
    open func setupTheme() {
        isThemeable = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeChanged),
                                               name: NSNotification.Name.ThemeChanged,
                                               object: nil)
    }
    
    open func updateTheme() {
        for child in subviews {
            if let view = child as? ThemeableView, view.isThemeable {
                view.updateTheme()
            }
        }
    }
}
