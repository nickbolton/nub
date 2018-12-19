//
//  CollectionViewController.swift
//  Nub
//
//  Created by Nick Bolton on 8/8/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

public protocol DataSourceHaving {
    func collectionItem(at indexPath: IndexPath) -> CollectionItem?
}

open class CollectionViewController<VT:CollectionRootView, DT:CollectionItem>: DataReloadingViewController<VT, UICollectionViewCell, DT>, DataSourceHaving {
    
    public var collectionView: UICollectionView { return rootView.collectionView }
    open override var dataView: UIView { return collectionView }
    
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
    
    // MARK: Data Source

    open override func dataSourceItem(for cell: UICollectionViewCell) -> DT? {
        if let indexPath = collectionView.indexPath(for: cell) {
            return dataSourceItem(at: indexPath)
        }
        
        return nil
    }
    
    open override func didReloadData() {
        super.didReloadData()
        collectionView.reloadData()
    }
    
    open func collectionItem(at indexPath: IndexPath) -> CollectionItem? {
        return dataSourceItem(at: indexPath)
    }
    
    // MARK: Theme
    
    open override func updateTheme() {
        guard isThemeable else { return }
        super.updateTheme()
        for cell in collectionView.visibleCells {
            if let themedCell = cell as? ThemeableView, themedCell.isThemeable {
                themedCell.updateTheme()
            }
        }
        collectionView.backgroundColor = view.backgroundColor
    }
        
    // MARK: UICollectionViewDataSource Conformance

    @objc public func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
//        return numberOfSections(in: collectionView)
//    }
//    
//    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let dataSource = self.dataSource {
            return dataSource.count
        }
        return 1
    }

    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionArray = dataSourceArray(at: section) {
            return sectionArray.count
        }
        return 0
    }    
}
