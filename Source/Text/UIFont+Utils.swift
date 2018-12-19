//
//  UIFont.swift
//  Nub
//
//  Created by Nick Bolton on 3/18/18.
//

import UIKit

public extension UIFont {
    
    internal static let smallTestPointSize: CGFloat = 8.0
    internal static let largeTestPointSize: CGFloat = 50.0
    
    public static func systemFont(systemFontWeight: SystemFontWeight, pointSize: CGFloat) -> UIFont {
        let defaultFont = UIFont.systemFont(ofSize: pointSize, weight: systemFontWeight.fontWeight)
        if systemFontWeight.isItalic {
            if let fontDescriptor = defaultFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
                return UIFont(descriptor: fontDescriptor, size: pointSize)
            }
        }
        return defaultFont
    }
}
