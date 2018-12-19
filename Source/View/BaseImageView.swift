//
//  BaseImageView.swift
//  Nub
//
//  Created by Nick Bolton on 7/5/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit

open class BaseImageView: UIImageView {

    private var didAddMissingConstraints = false;
        
    public convenience init() {
        self.init(frame: .zero)
    }
    
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
}
