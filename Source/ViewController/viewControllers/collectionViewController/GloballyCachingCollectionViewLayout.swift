//
//  GloballyCachingCollectionViewLayout.swift
//  Nub
//
//  Created by Nick Bolton on 3/5/19.
//

import UIKit

open class GloballyCachingCollectionViewLayout: BaseCollectionViewLayout {

    private var globalCache = [String: [IndexPath: UICollectionViewLayoutAttributes]]()
    
    open override func prepare() {
        oldLayoutInfo = layoutInfo
        
        var newLayoutInfo = [String: Dictionary<IndexPath, UICollectionViewLayoutAttributes>]()
        var cellLayoutInfo = [IndexPath: UICollectionViewLayoutAttributes]()
        //        var supplimentaryLayoutInfo = [IndexPath: UICollectionViewLayoutAttributes]()
        //        var decorationLayoutInfo = [IndexPath: UICollectionViewLayoutAttributes]()
        
        enumerateCollectionItems { (ip, attr, item) in
            if let attributes = globalCache[collectionViewCellKind]?[ip] {
                cellLayoutInfo[ip] = attributes
            } else {
                var attributes = attr
                if var item = item {
                    configure(attributes: &attributes, with: item, at: ip)
                }
                cellLayoutInfo[ip] = attributes
            }
        }
        
        newLayoutInfo[collectionViewCellKind] = cellLayoutInfo;
        //        newLayoutInfo[collectionViewSupplimentaryKind] = supplimentaryLayoutInfo;
        //        newLayoutInfo[collectionViewDecorationKind] = decorationLayoutInfo;
        
        if isDebugging {
            Logger.shared.debug("layoutInfo: \(newLayoutInfo)")
        }
        
        layoutInfo = newLayoutInfo
    }
}
