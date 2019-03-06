//
//  StyledLabel.swift
//  Nub iOS
//
//  Created by Nick Bolton on 3/4/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

public class StyledLabel: BaseLabel {

    public var style = TextStyle.defaultStyle { didSet { attributedText = style.attributedString } }
    public var styleText: String {
        get { return style.textDescriptors.map { $0.text }.first ?? "" }
        set { style.applyValues([newValue]) }
    }
    public var styleTextValues: [String] {
        get { return style.textDescriptors.map { $0.text } }
        set { style.applyValues(newValue) }
    }
}
