//
//  CollectionRootView.swift
//  Nub
//
//  Created by Nick Bolton on 8/8/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class CollectionRootView: BaseView {

    public let contentContainer = UIView()
    public var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    public let flowLayout = UICollectionViewFlowLayout()
    public var itemSize:CGSize = .zero
    
    open var customLayout: UICollectionViewLayout?
    
    // MARK: View Hierarchy Construction
    
    open override func initializeViews() {
        useSafeAreaContainer = true
        super.initializeViews()
        initializeCollectionView()
    }
    
    open override func assembleViews() {
        super.assembleViews()
        safeAreaContainer.addSubview(contentContainer)
        contentContainer.addSubview(collectionView)
    }
    
    open override func constrainViews() {
        super.constrainViews()
        constrainContentContainer()
        constrainCollectionView()
    }
        
    open func constrainContentContainer() {
        NSLayoutConstraint.activate([
            contentContainer.widthAnchor.constraint(equalTo: safeAreaContainer.widthAnchor),
            contentContainer.heightAnchor.constraint(equalTo: safeAreaContainer.heightAnchor),
            contentContainer.centerXAnchor.constraint(equalTo: safeAreaContainer.centerXAnchor),
            contentContainer.centerYAnchor.constraint(equalTo: safeAreaContainer.centerYAnchor),
            ])
    }

    private func initializeCollectionView() {
        flowLayout.minimumInteritemSpacing = 0.0;
        flowLayout.minimumLineSpacing = 0.0;
        
        if !itemSize.equalTo(.zero) {
            flowLayout.itemSize = itemSize;
        }
        
        let layout = customLayout ?? flowLayout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    open func constrainCollectionView() {
        NSLayoutConstraint.activate([
            collectionView.widthAnchor.constraint(equalTo: contentContainer.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: contentContainer.heightAnchor),
            collectionView.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
            ])
    }
}
