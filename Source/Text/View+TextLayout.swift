//
//  View+TextLayout.swift
//  Nub
//
//  Created by Nick Bolton on 3/18/18.
//

import UIKit

public extension UIView {

    @discardableResult
    public func alignTop(for style: TextStyle, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignTop(offset: -metrics.textMargins.top + offset)
    }
    
    @discardableResult
    public func alignTop(for style: TextStyle, toBottomOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignTop(toBottomOf: targetView, offset: -metrics.textMargins.top - targetMetrics.textMargins.bottom + offset)
    }

    @discardableResult
    public func alignTop(for style: TextStyle, toTopOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignTop(toTopOf: targetView, offset: -metrics.textMargins.top + targetMetrics.textMargins.top + offset)
    }

    @discardableResult
    public func alignTop(for style: TextStyle, toBottomOf targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignTop(toBottomOf: targetView, offset: -metrics.textMargins.top + offset)
    }
    
    @discardableResult
    public func alignTop(for style: TextStyle, toBaselineOf targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignTop(toBaselineOf: targetView, offset: -metrics.textMargins.top + offset)
    }
    
    @discardableResult
    public func alignTop(toBaselineOf style: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignTop(toBaselineOf: targetView, offset: -metrics.textMargins.top + offset)
    }
    
    @discardableResult
    public func alignLeading(for style: TextStyle, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignLeading(offset: -metrics.textMargins.left + offset - 0.5)
    }
    
    @discardableResult
    public func alignLeading(for style: TextStyle, toLeadingOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignLeading(toLeadingOf: targetView, offset: -metrics.textMargins.left + targetMetrics.textMargins.left + offset)
    }
    
    @discardableResult
    public func alignLeading(for style: TextStyle, toTrailingOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignLeading(toTrailingOf: targetView, offset: -metrics.textMargins.left - targetMetrics.textMargins.right + offset - 0.75)
    }
    
    @discardableResult
    public func alignTrailing(for style: TextStyle, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignTrailing(offset: metrics.textMargins.right + offset)
    }
    
    @discardableResult
    public func alignTrailing(for style: TextStyle, toTrailingOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignTrailing(toTrailingOf: targetView, offset: metrics.textMargins.right - targetMetrics.textMargins.right + offset - 0.75)
    }
    
    @discardableResult
    public func alignTrailing(for style: TextStyle, toLeadingOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignTrailing(toLeadingOf: targetView, offset: metrics.textMargins.right + targetMetrics.textMargins.left + offset)
    }
    
    @discardableResult
    public func alignLeft(for style: TextStyle, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignLeft(offset: -metrics.textMargins.left + offset - 0.5)
    }
    
    @discardableResult
    public func alignLeft(for style: TextStyle, toLeftOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignLeft(toLeftOf: targetView, offset: -metrics.textMargins.left + targetMetrics.textMargins.left + offset)
    }
    
    @discardableResult
    public func alignLeft(for style: TextStyle, toRightOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignLeft(toRightOf: targetView, offset: -metrics.textMargins.left - targetMetrics.textMargins.right + offset - 0.75)
    }
    
    @discardableResult
    public func alignRight(for style: TextStyle, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset:CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        return alignRight(offset: metrics.textMargins.right + offset)
    }
    
    @discardableResult
    public func alignRight(for style: TextStyle, toRightOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignRight(toRightOf: targetView, offset: metrics.textMargins.right - targetMetrics.textMargins.right + offset - 0.75)
    }
    
    @discardableResult
    public func alignRight(for style: TextStyle, toLeftOf targetStyle: TextStyle, targetView: UIView, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: style, textType: .label, boundBy: boundBy)
        let targetMetrics = TextMetricsCache.shared.textMetrics(for: targetStyle, textType: .label, boundBy: boundBy)
        return alignRight(toLeftOf: targetView, offset: metrics.textMargins.right + targetMetrics.textMargins.left + offset)
    }

    @discardableResult
    public func layoutWidth(for style: TextStyle, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let textFrame = style.textViewFrame(for: .label, boundBy: boundBy, usePreciseTextAlignments: false, containerSize: boundBy)
        return layout(width: textFrame.width + offset)
    }
    
    @discardableResult
    public func layoutHeight(for style: TextStyle, width: CGFloat = CGFloat.greatestFiniteMagnitude, offset: CGFloat = 0.0) -> NSLayoutConstraint {
        let boundBy = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textFrame = style.textViewFrame(for: .label, boundBy: boundBy, usePreciseTextAlignments: false, containerSize: boundBy)
        return layout(height: textFrame.height + offset)
    }
}
