//
//  CollectionViewController2.swift
//  Nub
//
//  Created by Nick Bolton on 11/17/18.
//

import UIKit

open class CollectionViewController2<VT:CollectionRootView>: BaseViewController<VT> {

    public var collectionView: UICollectionView { return rootView.collectionView }
    
    // MARK: Setup
    
    open func setupCollectionView() {
        registerCollectionViewCells()
    }
    
    open func registerCollectionViewCells() {
    }
    
    // MARK: View Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView.collectionViewLayout as? BaseCollectionViewLayout {
            layout.viewController = self
        }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setupCollectionView()
    }
}
