//
//  TableViewController.swift
//  Nub
//
//  Created by Nick Bolton on 9/2/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class TableViewController<VT:TableRootView, DT:NSObject>: DataReloadingViewController<VT, UITableViewCell, DT> {
    
    public var tableView: UITableView { return rootView.tableView }
    open override var dataView: UIView { return tableView }
    
    open var tableViewDataSource: UITableViewDataSource? { get { return nil } }
    open var tableViewDelegate: UITableViewDelegate? { get { return nil } }
    
    // MARK: Setup
    
    open func setupTableView() {
        registerTableViewCells()
    }
    
    open func registerTableViewCells() {
    }
    
    // MARK: View Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setupTableView()
    }
    
    // MARK: Data Source
        
    open override func dataSourceItem(for cell: UITableViewCell) -> DT? {
        if let indexPath = tableView.indexPath(for: cell) {
            return dataSourceItem(at: indexPath)
        }
        
        return nil
    }
    
    open override func didReloadData() {
        super.didReloadData()
        tableView.reloadData()
    }
    
    // MARK: Theme
    
    open override func updateTheme() {
        guard isThemeable else { return }
        super.updateTheme()
        for cell in tableView.visibleCells {
            if let themedCell = cell as? ThemeableView, themedCell.isThemeable {
                themedCell.updateTheme()
            }
        }
        tableView.backgroundColor = view.backgroundColor
    }
    
    // MARK: UITableViewDataSource Helpers
    
    @objc public func numberOfRows(in section: Int) -> Int {
        if let sectionArray = dataSourceArray(at: section) {
            return sectionArray.count
        }
        
        return 0
    }
    
    @objc public func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        if let dataSource = self.dataSource {
            return dataSource.count
        }
        
        return 0
    }
}
