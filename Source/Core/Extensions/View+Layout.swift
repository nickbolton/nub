//
//  View+Layout.swift
//  Nub
//
//  Created by Nick Bolton on 6/28/16.
//  Copyright © 2016 Pixelbleed, LLC. All rights reserved.
//

import UIKit

public extension UIView {
        
    public func constraint(with attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        for constraint in constraints {
            if (attribute == constraint.firstAttribute && constraint.firstItem as! NSObject == self) ||
                (attribute == constraint.secondAttribute && constraint.secondItem as! NSObject == self) {
                return constraint
            }
        }
        return nil
    }
    
    public func constraints(with attribute: NSLayoutConstraint.Attribute) -> [NSLayoutConstraint] {
        var result = [NSLayoutConstraint]()
        for constraint in constraints {
            if (attribute == constraint.firstAttribute && constraint.firstItem as! NSObject == self) ||
                (attribute == constraint.secondAttribute && constraint.secondItem as! NSObject == self) {
                result.append(constraint)
            }
        }
        return result
    }
    
    @discardableResult
    public func layout(minWidth:CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .width,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: minWidth)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func layout(maxWidth:CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .width,
                                        relatedBy: .lessThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: maxWidth)
        result.priority = priority
        NSLayoutConstraint.activate([result])

        return result
    }

    @discardableResult
    public func layout(width:CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .width,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: width)
        result.priority = priority
        NSLayoutConstraint.activate([result])

        return result
    }
    
    @discardableResult
    public func layout(minWidth:CGFloat, maxWidth:CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var result = Array<NSLayoutConstraint>()
        let minConstraint = layout(minWidth: minWidth, priority: priority)
        let maxConstraint = layout(maxWidth: maxWidth, priority: priority)
        result.append(minConstraint)
        result.append(maxConstraint)
        
        return result
    }
    
    @discardableResult
    public func layout(minHeight:CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: minHeight)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func layout(maxHeight:CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .height,
                                        relatedBy: .lessThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: maxHeight)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func layout(height:CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .height,
                                        relatedBy: relatedBy,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: height)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func layout(minHeight:CGFloat, maxHeight:CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var result = Array<NSLayoutConstraint>()
        let minConstraint = layout(minHeight: minHeight, priority: priority)
        let maxConstraint = layout(maxHeight: maxHeight, priority: priority)
        result.append(minConstraint)
        result.append(maxConstraint)
        
        return result
    }
    
    @discardableResult
    public func layout(size:CGSize, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var result = Array<NSLayoutConstraint>()
        let widthConstraint = layout(width: size.width, relatedBy: relatedBy, priority: priority)
        let heightConstraint = layout(height: size.height, relatedBy: relatedBy, priority: priority)
        result.append(widthConstraint)
        result.append(heightConstraint)
        
        return result
    }
    
    @discardableResult
    public func centerView(relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var result = Array<NSLayoutConstraint>()
        let horizontalConstraint = centerX(relatedBy: relatedBy, priority: priority)
        let verticalConstraint = centerY(relatedBy: relatedBy, priority: priority);
        result.append(horizontalConstraint)
        result.append(verticalConstraint)
        
        return result
    }
    
    @discardableResult
    public func centerX(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerX(to: superview, offset: offset, relatedBy: relatedBy, priority: priority)
    }
    
    @discardableResult
    public func centerX(toLeftOf toView: UIView?, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerX(to: toView, atPosition: .left, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func centerXToLeft(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerX(toLeftOf: superview, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func centerX(toRightOf toView: UIView?, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerX(to: toView, atPosition: .right, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func centerXToRight(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerX(toRightOf: superview, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func centerX(to toView: UIView?, atPosition position: NSLayoutConstraint.Attribute = .centerX, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .centerX,
                                        relatedBy: relatedBy,
                                        toItem: toView,
                                        attribute: position,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func centerY(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerY(to: superview, offset: offset, relatedBy: relatedBy, priority: priority)
    }
    
    @discardableResult
    public func centerY(toTopOf toView: UIView?, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerY(to: toView, atPosition: .top, offset: offset, relatedBy: relatedBy, priority: priority)
    }
    
    @discardableResult
    public func centerYToTop(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerY(toTopOf: superview, offset: offset, relatedBy: relatedBy, priority: priority)
    }
    
    @discardableResult
    public func centerY(toBottomOf toView: UIView?, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerY(to: toView, atPosition: .bottom, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func centerY(toBaselineOf toView: UIView?, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerY(to: toView, atPosition: .lastBaseline, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func centerYToBottom(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return centerY(toBottomOf: superview, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func centerY(to toView: UIView?, atPosition position: NSLayoutConstraint.Attribute = .centerY, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .centerY,
                                        relatedBy: relatedBy,
                                        toItem: toView,
                                        attribute: position,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func expandWidth(insets:UIEdgeInsets = .zero, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var result = Array<NSLayoutConstraint>()
        let leftConstraint = alignLeft(offset: insets.left, priority: priority)
        let rightConstraint = alignRight(offset: -insets.right, priority: priority)
        result.append(leftConstraint)
        result.append(rightConstraint)
        
        return result
    }
    
    @discardableResult
    public func expandHeight(insets:UIEdgeInsets = .zero, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var result = Array<NSLayoutConstraint>()
        let topConstraint = alignTop(offset: insets.top, priority: priority)
        let bottomConstraint = alignBottom(offset: -insets.bottom, priority: priority)
        result.append(topConstraint)
        result.append(bottomConstraint)
        
        return result
    }
    
    @discardableResult
    public func expand(insets:UIEdgeInsets = .zero, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        var result = Array<NSLayoutConstraint>()
        let horizontalConstraint = expandWidth(insets: insets, priority: priority)
        let verticalConstraint = expandHeight(insets: insets, priority: priority)
        result.append(contentsOf: horizontalConstraint)
        result.append(contentsOf: verticalConstraint)
        
        return result
    }
    
    @discardableResult
    public func expandToSafeArea(insets:UIEdgeInsets = .zero, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        var safeAreaItem: Any = superview!
        if #available(iOS 11, *) {
            safeAreaItem = safeAreaLayoutGuide
        }
        
        let leftConstraint = NSLayoutConstraint(item: self,
                                                attribute: .left,
                                                relatedBy: .equal,
                                                toItem: safeAreaItem,
                                                attribute: .left,
                                                multiplier: 1.0,
                                                constant: insets.left)
        let rightConstraint = NSLayoutConstraint(item: safeAreaItem,
                                                 attribute: .right,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .right,
                                                 multiplier: 1.0,
                                                 constant: insets.right)
        let topConstraint = NSLayoutConstraint(item: self,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: safeAreaItem,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: insets.top)
        let bottomConstraint = NSLayoutConstraint(item: safeAreaItem,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: insets.bottom)
        
        let result = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
        for c in result {
            c.priority = priority
        }
        NSLayoutConstraint.activate(result)
        return result
    }

    @discardableResult
    public func alignWidth(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return alignWidth(to: nil, offset: offset, relatedBy: relatedBy, priority: priority)
    }

    @discardableResult
    public func alignWidth(to target: UIView? = nil, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        
        let targetView = target ?? superview
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .width,
                                        relatedBy: relatedBy,
                                        toItem: targetView,
                                        attribute: .width,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignWidthPercent(_ percent: CGFloat, to target: UIView? = nil, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        
        let targetView = target ?? superview
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .width,
                                        relatedBy: relatedBy,
                                        toItem: targetView,
                                        attribute: .width,
                                        multiplier: percent,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignWidth(toHeightOf target: UIView? = nil, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let targetView = target ?? superview
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .width,
                                        relatedBy: relatedBy,
                                        toItem: targetView,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignHeight(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return alignHeight(to: nil, offset: offset, relatedBy: relatedBy, priority: priority)
    }
    
    @discardableResult
    public func alignHeight(to target: UIView? = nil, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        
        let targetView = target ?? superview
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .height,
                                        relatedBy: relatedBy,
                                        toItem: targetView,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignHeightPercent(_ percent: CGFloat, to target: UIView? = nil, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        
        let targetView = target ?? superview
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .height,
                                        relatedBy: relatedBy,
                                        toItem: targetView,
                                        attribute: .height,
                                        multiplier: percent,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignHeight(toWidthOf target: UIView? = nil, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let targetView = target ?? superview
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .height,
                                        relatedBy: relatedBy,
                                        toItem: targetView,
                                        attribute: .width,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }
    
    @discardableResult
    public func alignTop(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: relatedBy,
                                        toItem: self.superview,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignSafeAreaTop(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignBottom(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: relatedBy,
                                        toItem: self.superview,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignSafeAreaBottom(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignBaseline(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .lastBaseline,
                                        relatedBy: relatedBy,
                                        toItem: self.superview,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignSafeAreaBaseline(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = lastBaselineAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignLeading(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .leading,
                                        relatedBy: relatedBy,
                                        toItem: self.superview,
                                        attribute: .leading,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignSafeAreaLeading(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignLeading(toLeadingOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .leading,
                                        relatedBy: relatedBy,
                                        toItem: toLeadingOf,
                                        attribute: .leading,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignLeading(toTrailingOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .leading,
                                        relatedBy: relatedBy,
                                        toItem: toTrailingOf,
                                        attribute: .trailing,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignLeading(toCenterOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .leading,
                                        relatedBy: relatedBy,
                                        toItem: toCenterOf,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTrailing(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .trailing,
                                        relatedBy: relatedBy,
                                        toItem: self.superview,
                                        attribute: .trailing,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignSafeAreaTrailing(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignTrailing(toTrailingOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .trailing,
                                        relatedBy: relatedBy,
                                        toItem: toTrailingOf,
                                        attribute: .trailing,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTrailing(toLeadingOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .trailing,
                                        relatedBy: relatedBy,
                                        toItem: toLeadingOf,
                                        attribute: .leading,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTrailing(toCenterOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .trailing,
                                        relatedBy: relatedBy,
                                        toItem: toCenterOf,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignLeft(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .left,
                                        relatedBy: relatedBy,
                                        toItem: self.superview,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignSafeAreaLeft(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignRight(offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .right,
                                        relatedBy: relatedBy,
                                        toItem: self.superview,
                                        attribute: .right,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignSafeAreaRight(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        return result
    }

    @discardableResult
    public func alignFirstBaseline(toBaselineOf: UIView, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return alignFirstBaseline(toBaselineOf: toBaselineOf, offset: 0.0, relatedBy: relatedBy, priority: priority)
    }
    
    @discardableResult
    public func alignFirstBaseline(toBaselineOf: UIView, offset: CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .firstBaseline,
                                        relatedBy: relatedBy,
                                        toItem: toBaselineOf,
                                        attribute: .lastBaseline,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func verticallySpace(toView: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: relatedBy,
                                        toItem: toView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func horizontallySpace(toView: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .left,
                                        relatedBy: relatedBy,
                                        toItem: toView,
                                        attribute: .right,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTop(toTopOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: relatedBy,
                                        toItem: toTopOf,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTop(toCenterOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: relatedBy,
                                        toItem: toCenterOf,
                                        attribute: .centerY,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTop(toFirstBaselineOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: relatedBy,
                                        toItem: toFirstBaselineOf,
                                        attribute: .firstBaseline,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignFirstBaseline(toBottomOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .firstBaseline,
                                        relatedBy: relatedBy,
                                        toItem: toBottomOf,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTop(toBottomOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: relatedBy,
                                        toItem: toBottomOf,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignTop(toBaselineOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .top,
                                        relatedBy: relatedBy,
                                        toItem: toBaselineOf,
                                        attribute: .lastBaseline,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignBottom(toTopOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: relatedBy,
                                        toItem: toTopOf,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignBottom(toCenterOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: relatedBy,
                                        toItem: toCenterOf,
                                        attribute: .centerY,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignBottom(toBottomOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: relatedBy,
                                        toItem: toBottomOf,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignBottom(toBaselineOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: relatedBy,
                                        toItem: toBaselineOf,
                                        attribute: .lastBaseline,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignBaseline(toTopOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .lastBaseline,
                                        relatedBy: relatedBy,
                                        toItem: toTopOf,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignBaseline(toBottomOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .lastBaseline,
                                        relatedBy: relatedBy,
                                        toItem: toBottomOf,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignBaseline(toBaselineOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .lastBaseline,
                                        relatedBy: relatedBy,
                                        toItem: toBaselineOf,
                                        attribute: .lastBaseline,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignBaseline(toFirstBaselineOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .lastBaseline,
                                        relatedBy: relatedBy,
                                        toItem: toFirstBaselineOf,
                                        attribute: .firstBaseline,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignBottom(toFirstBaselineOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: relatedBy,
                                        toItem: toFirstBaselineOf,
                                        attribute: .firstBaseline,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignLeft(toLeftOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .left,
                                        relatedBy: relatedBy,
                                        toItem: toLeftOf,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignLeft(toCenterOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .left,
                                        relatedBy: relatedBy,
                                        toItem: toCenterOf,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }

    @discardableResult
    public func alignLeft(toRightOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .left,
                                        relatedBy: relatedBy,
                                        toItem: toRightOf,
                                        attribute: .right,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignRight(toRightOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .right,
                                        relatedBy: relatedBy,
                                        toItem: toRightOf,
                                        attribute: .right,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignRight(toCenterOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .right,
                                        relatedBy: relatedBy,
                                        toItem: toCenterOf,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
    
    @discardableResult
    public func alignRight(toLeftOf: UIView, offset: CGFloat = 0.0, relatedBy: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let result = NSLayoutConstraint(item: self,
                                        attribute: .right,
                                        relatedBy: relatedBy,
                                        toItem: toLeftOf,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: offset)
        result.priority = priority
        NSLayoutConstraint.activate([result])
        
        return result
    }
}
