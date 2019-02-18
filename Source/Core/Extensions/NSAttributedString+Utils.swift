//
//  NSAttributedString+Utils.swift
//  Bedrock
//
//  Created by Nick Bolton on 5/20/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit

extension NSAttributedString {

    public func textSize(width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        return textSizeWithSize(CGSize(width: width, height: height))
    }
    
    public func textSizeWithSize(_ size: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> CGSize {
        let options = NSStringDrawingOptions.usesLineFragmentOrigin.union(.usesFontLeading)
        let rect = boundingRect(with: size, options: options, context: nil)
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
    
    public func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin.union(.usesFontLeading)
        let boundingBox = boundingRect(with: constraintRect, options: options, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    public func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin.union(.usesFontLeading)
        let boundingBox = boundingRect(with: constraintRect, options: options, context: nil)
        
        return ceil(boundingBox.width)
    }
    
    public func allFonts() -> [UIFont] {
        var result = [UIFont]()
        enumerateAttributes(in: NSMakeRange(0, length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (attrs, range, _) in
            if let font = attrs[.font] as? UIFont {
                result.append(font)
            }
        }
        return result
    }
}
