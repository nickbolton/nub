//
//  BaseTableViewCell.swift
//  Nub
//
//  Created by Nick Bolton on 8/10/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//

import UIKit

open class BaseTableViewCell: UITableViewCell {

    var didAddMissingConstraints = false;
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _commonInit()
    }
    
    // MARK: Setup
    
    private func _commonInit() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
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
