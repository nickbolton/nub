//
//  ConstrainingTextView.swift
//  Nub
//
//  Created by Nick Bolton on 1/20/19.
//

import UIKit

class ConstrainingTextView: BaseTextView {

    private (set) public var widthConstraint: NSLayoutConstraint?
    private (set) public var heightConstraint: NSLayoutConstraint?
    
    public var constrainingType = ConstrainingType.height
    
    private var lastCrossDimensionUsed: CGFloat = 0.0
    
    public var contentHeight: CGFloat {
        let size = CGSize(width: lastCrossDimensionUsed,
                          height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if let attributedText = attributedText {
            return attributedText.boundingRect(with: size,
                                               options: options,
                                               context: nil).height
        }
        guard let font = font else { return 0.0 }
        return (text ?? "").textSize(using: font, withBounds: size).height
    }
    
    public var contentWidth: CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude,
                          height: lastCrossDimensionUsed)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if let attributedText = attributedText {
            return attributedText.boundingRect(with: size,
                                               options: options,
                                               context: nil).width
        }
        guard let font = font else { return 0.0 }
        return (text ?? "").textSize(using: font, withBounds: size).width
    }
    
    override func initializeViews() {
        super.initializeViews()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if constrainingType == .height {
            if lastCrossDimensionUsed != bounds.width {
                lastCrossDimensionUsed = bounds.width
                setNeedsUpdateConstraints()
            }
        } else {
            if lastCrossDimensionUsed != bounds.height {
                lastCrossDimensionUsed = bounds.height
                setNeedsUpdateConstraints()
            }
        }
    }
    
    // MARK: Constraints
    
    override func updateConstraints() {
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        if constrainingType == .height {
            heightConstraint = heightAnchor.constraint(equalToConstant: contentHeight)
            heightConstraint?.isActive = true
        } else {
            widthConstraint = widthAnchor.constraint(equalToConstant: contentWidth)
            widthConstraint?.isActive = true
        }
        super.updateConstraints()
    }
}
