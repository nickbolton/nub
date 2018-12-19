//
//  PagingCollectionViewFlowLayout.swift
//  Nub
//
//  Created by Nick Bolton on 8/11/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class PagingCollectionViewFlowLayout: UICollectionViewFlowLayout {

    // MARK: Pagination
    
    private var pageSize: CGFloat {
        get {
            if (isHorizontal) {
                return itemSize.width + minimumLineSpacing
            }
            return itemSize.height + minimumInteritemSpacing
        }
    }
    
    private var isHorizontal: Bool {
        get {
            return scrollDirection == .horizontal
        }
    }
    
    var isFastPaging: Bool = false
    
    open override func targetContentOffset(forProposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var proposedContentOffset = forProposedContentOffset
        
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }
        var offSetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = (CGFloat)(proposedContentOffset.x + (collectionView.bounds.width / 2.0))
        //setting fastPaging property to NO allows to stop at page on screen (I have pages lees, than self.collectionView.bounds.size.width)
        let targetRect = CGRect(x: CGFloat(isFastPaging ? proposedContentOffset.x : collectionView.contentOffset.x), y: CGFloat(0.0), width: CGFloat(collectionView.bounds.width), height: CGFloat(collectionView.bounds.height))
        let attributes: [Any]? = layoutAttributesForElements(in: targetRect)
        let cellAttributesPredicate = NSPredicate { (_ evaluatedObject: Any?, _ bindings: [String: Any]?) -> Bool in
            if let obj = evaluatedObject as? UICollectionViewLayoutAttributes {
                return obj.representedElementCategory == .cell
            }
            return false
        }
            
        var currentAttributes: UICollectionViewLayoutAttributes?
        if let cellAttributes = (attributes?.filter { cellAttributesPredicate.evaluate(with: $0) }) as? [UICollectionViewLayoutAttributes] {
            for layoutAttributes: UICollectionViewLayoutAttributes in cellAttributes {
                let itemHorizontalCenter: CGFloat = layoutAttributes.center.x
                if abs(itemHorizontalCenter - horizontalCenter) < abs(offSetAdjustment) {
                    currentAttributes = layoutAttributes
                    offSetAdjustment = itemHorizontalCenter - horizontalCenter
                }
            }
            
            if let currentAttributes = currentAttributes {
                let nextOffset = proposedContentOffset.x + offSetAdjustment
                proposedContentOffset.x = nextOffset
                let deltaX = proposedContentOffset.x - collectionView.contentOffset.x
                let velX = velocity.x
                // detection form  gist.github.com/rkeniger/7687301
                // based on http://stackoverflow.com/a/14291208/740949
                if abs(deltaX) <= CGFloat(Float.ulpOfOne) || abs(velX) <= CGFloat(Float.ulpOfOne) || (velX > 0.0 && deltaX > 0.0) || (velX < 0.0 && deltaX < 0.0) {
                    
                }
                else if velocity.x > 0.0 {
                    // revert the array to get the cells from the right side, fixes not correct center on different size in some usecases
                    let revertedArray = cellAttributes.reversed()
                    var found: Bool = true
                    var proposedX: CGFloat = 0.0
                    for layoutAttributes: UICollectionViewLayoutAttributes in revertedArray {
                        if layoutAttributes.representedElementCategory == .cell {
                            let itemHorizontalCenter: CGFloat = layoutAttributes.center.x
                            if itemHorizontalCenter > proposedContentOffset.x {
                                found = true
                                proposedX = nextOffset + (currentAttributes.frame.width / 2.0) + (layoutAttributes.frame.width / 2.0)
                            }
                            else {
                                break
                            }
                        }
                    }
                    // dont set on unfound element
                    if found {
                        proposedContentOffset.x = proposedX
                    }
                }
                else if velocity.x < 0.0 {
                    for layoutAttributes: UICollectionViewLayoutAttributes in cellAttributes {
                        let itemHorizontalCenter: CGFloat = layoutAttributes.center.x
                        if itemHorizontalCenter > proposedContentOffset.x {
                            proposedContentOffset.x = nextOffset - (currentAttributes.frame.width / 2.0) + (layoutAttributes.frame.width / 2.0)
                            break
                        }
                    }
                }
            }
        }
        proposedContentOffset.y = 0.0
        return proposedContentOffset
    }
}
