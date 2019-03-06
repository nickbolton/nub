//
//  StyledTextCollectionReusableView.swift
//  Nub iOS
//
//  Created by Nick Bolton on 3/4/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

public class StyledTextCollectionReusableView: BaseCollectionReusableView {
    
    public let styledLabel = StyledLabel()
    
    // MARK: Begin View Hierarchy Construction

    override public func initializeViews() {
        super.initializeViews()
        initializeStyledLabel()
    }

    override public func assembleViews() {
        super.assembleViews()
        addSubview(styledLabel)
    }

    override public func constrainViews() {
        super.constrainViews()
        constrainStyledLabel()
    }

    // MARK: Styled Label

    private func initializeStyledLabel() {
    }

    private func constrainStyledLabel() {
        styledLabel.expand()
    }

    // MARK: End View Hierarchy Construction
}
