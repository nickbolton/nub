//
//  CollectionRootView.swift
//  Nub
//
//  Created by Nick Bolton on 8/8/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class CollectionRootView: BaseView {

    public var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    public let flowLayout = UICollectionViewFlowLayout()
    public var itemSize:CGSize = .zero
    
    public var anchorToSafeArea = true
    
    open var customLayout: UICollectionViewLayout?
    
    // MARK: View Hierarchy Construction
    
    open override func initializeViews() {
        super.initializeViews()
        initializeCollectionView()
    }
    
    open override func assembleViews() {
        super.assembleViews()
        addSubview(collectionView)
    }
    
    open override func constrainViews() {
        super.constrainViews()
        constrainCollectionView()
        
    }
    
    open func initializeCollectionView() {
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        
        if !itemSize.equalTo(.zero) {
            flowLayout.itemSize = itemSize
        }
        
        let layout = customLayout ?? flowLayout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    open func constrainCollectionView() {
        if anchorToSafeArea {
            NSLayoutConstraint.activate([
                collectionView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                collectionView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
                collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                ])
        } else {
            NSLayoutConstraint.activate([
                collectionView.leftAnchor.constraint(equalTo: leftAnchor),
                collectionView.rightAnchor.constraint(equalTo: rightAnchor),
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
              ])
        }
    }
}
