//
//  DataReloadingViewController.swift
//  Nub
//
//  Created by Nick Bolton on 8/9/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class DataReloadingViewController<T:UIView, CT, DT>: BaseViewController<T> {

    public var needsReloadOnWillAppear = true
    public var dataSource: [[DT]]?
    open var dataView: UIView { return view }
    public var isClearingData = false
    private (set) public var isReloadingData = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        observeApplicationWillEnterForeground()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needsReloadOnWillAppear {
            needsReloadOnWillAppear = false
            reloadData()
        }
    }
    
    // MARK: Abstract Functions
    
    open func buildDataSource() -> [[DT]] {
        // abstract
        return []
    }
    
    open func buildDataSource(success: (([[DT]]?) -> Void)?, failure: DefaultFailureHandler?) -> Bool {
        // abstract
        return false
    }
    
    open func dataSourceItem(for cell: CT) -> DT? {
        // abstract
        return nil
    }
    
    // MARK: Data Source
    
    open func clearData(_ animated: Bool = false) {
        isClearingData = true
        guard animated else {
            _clearData()
            return
        }
        
        UIView.transition(with: dataView,
                          duration: ThemeManager.shared.currentTheme().defaultAnimationDuration,
                          options: .transitionCrossDissolve,
                          animations: {
            self._clearData()
        }) { _ in
            self.isClearingData = false
        }
    }
    
    private func _clearData() {
        dataSource = nil
        finishedReloadingData()
    }
    
    open func reloadDataIfAppearing() {
        if isAppearing {
            reloadData(false)
        } else {
            clearData()
            needsReloadOnWillAppear = true
        }
    }
    
    open func reloadData(_ animated: Bool = false) {
        guard !isReloadingData else { return }
        guard animated else {
            _reloadData()
            return
        }
        
        UIView.transition(with: dataView,
                          duration: ThemeManager.shared.currentTheme().defaultAnimationDuration,
                          options: .transitionCrossDissolve,
                          animations: { 
            self._reloadData()
        }, completion: nil)
    }
    
    func _reloadData() {
        guard !isReloadingData else { return }
        isReloadingData = true
        willReloadData()
        
        let asyncOperation =
            buildDataSource(success: { [weak self] (dataSource) in
                guard let `self` = self else { return }
                self.dataSource = dataSource
                self.finishedReloadingData()
            }) { [weak self] (error) in
                self?.isReloadingData = false
                Logger.shared.error("Error occurred building async data source: \(String(describing: error))")
            }
        
        if (!asyncOperation) {
            reloadDataSource()
            finishedReloadingData()
        }
    }
    
    private func finishedReloadingData() {
        isReloadingData = false
        didReloadData()
    }
    
    open func willReloadData() {
    }
    
    open func didReloadData() {
    }
    
    public func dataSourceArray(at section: Int) -> [DT]? {
        
        guard let dataSource = self.dataSource else {
            return nil
        }
        
        var result: [DT]? = nil;
        
        if (section < dataSource.count) {
            result = dataSource[section];
        }
        
        return result;
    }
    
    public func dataSourceItem(at indexPath: IndexPath) -> DT? {
        
        if let sectionArray = dataSourceArray(at: indexPath.section) {
            if indexPath.row >= 0 && indexPath.row < sectionArray.count {
                return sectionArray[indexPath.row];
            }
        }
        return nil;
    }
    
    open func reloadDataSource() {
        dataSource = buildDataSource()
    }
    
    // MARK: Notifications
    
    override open func applicationWillEnterForeground(noti: NSNotification) {
        super.applicationWillEnterForeground(noti: noti)
        reloadDataIfAppearing()
    }
}
