//
//  UIButton+Layout.swift
//  Bedrock
//
//  Created by Nick Bolton on 3/25/18.
//

import UIKit

extension UIButton {
    
    public static let minTappableDimension: CGFloat = 44.0
    public static let minTappableSize = CGSize(width: minTappableDimension, height: minTappableDimension)
    
    @discardableResult
    public func alignImageLeft(width:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageWidth = image(for: .normal)?.size.width ?? 0.0
        let constant = offset - ((width - imageWidth) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .left,
                                        relatedBy: .equal,
                                        toItem: self.superview,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignImageLeft(toLeftOf:UIView, width:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageWidth = image(for: .normal)?.size.width ?? 0.0
        let constant = offset - ((width - imageWidth) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .left,
                                        relatedBy: .equal,
                                        toItem: toLeftOf,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignImageRight(width:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageWidth = image(for: .normal)?.size.width ?? 0.0
        let constant = offset + ((width - imageWidth) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .right,
                                        relatedBy: .equal,
                                        toItem: self.superview,
                                        attribute: .right,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignImageRight(toRightOf:UIView, width:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageWidth = image(for: .normal)?.size.width ?? 0.0
        let constant = offset + ((width - imageWidth) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .right,
                                        relatedBy: .equal,
                                        toItem: toRightOf,
                                        attribute: .right,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignImageTop(height:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = image(for: .normal)?.size.height ?? 0.0
        let constant = offset - ((height - imageHeight) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.superview,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignImageTop(toTopOf:UIView, height:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = image(for: .normal)?.size.height ?? 0.0
        let constant = offset - ((height - imageHeight) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: toTopOf,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignImageBottom(height:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = image(for: .normal)?.size.height ?? 0.0
        let constant = offset + ((height - imageHeight) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: self.superview,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignImageBottom(toBottomOf:UIView, height:CGFloat, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = image(for: .normal)?.size.height ?? 0.0
        let constant = offset + ((height - imageHeight) / 2.0)
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: toBottomOf,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: constant)
        NSLayoutConstraint.activate([result])
        
        return result
    }
}
