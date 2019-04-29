//
//  CollectionItem.swift
//  Nub
//
//  Created by Nick Bolton on 8/8/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class CollectionItem: NSObject {

    public var useCenter = false
    public var entity: Any?
    public var indexPath: IndexPath?
    
    // properties passed directly to UICollectionViewLayoutAttributes

    public var point: CGPoint = .zero
    public var center: CGPoint = .zero
    public var size: CGSize = .zero
    public var transform3D: CATransform3D = CATransform3DIdentity
    public var transform: CGAffineTransform = .identity
    public var alpha: CGFloat = 1.0
    public var zIndex: Int = 0
    public var isHidden = false

    @discardableResult
    public func set(entity: Any) -> Self {
        self.entity = entity
        return self
    }
}
