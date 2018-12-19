//
//  CGFloat+Utils.swift
//  Nub
//
//  Created by Nick Bolton on 2/13/18.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

extension CGFloat {
    public var halfPointCeilValue: CGFloat { return ceilWith(precision: 2.0) }
    public var halfPointRoundValue: CGFloat { return roundWith(precision: 2.0) }
        
    public func roundWith(precision: CGFloat) -> CGFloat {
        if precision > 1.0 {
            return Darwin.round(self * precision) / precision;
        }
        return self;
    }
    
    public func ceilWith(precision: CGFloat) -> CGFloat {
        if precision > 1.0 {
            return Darwin.ceil(self * precision) / precision
        }
        return self
    }
    
    public var truncatedSmallValue: CGFloat {
        let epsilon: CGFloat = 0.0001
        return abs(self) < epsilon ? 0.0 : self
    }
}

extension CGPoint {
    public var truncatedSmallValue: CGPoint {
        return CGPoint(x: x.truncatedSmallValue, y: y.truncatedSmallValue)
    }
}

extension CGSize {
    public var truncatedSmallValue: CGSize {
        return CGSize(width: width.truncatedSmallValue, height: height.truncatedSmallValue)
    }
}

extension CGVector {
    public var truncatedSmallValue: CGVector {
        return CGVector(dx: dx.truncatedSmallValue, dy: dy.truncatedSmallValue)
    }
}

extension CGRect {
    public var truncatedSmallValue: CGRect {
        return CGRect(origin: origin.truncatedSmallValue, size: size.truncatedSmallValue)
    }
}
