//
//  TableRootView.swift
//  Nub
//
//  Created by Nick Bolton on 9/2/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class TableRootView: BaseView {

    public let contentContainer = UIView()
    public let tableView = UITableView()
    
    // MARK: View Hierarchy Construction
    
    open override func initializeViews() {
        useSafeAreaContainer = true
        super.initializeViews()
        initializeTableView()
    }
    
    open override func assembleViews() {
        super.assembleViews()
        safeAreaContainer.addSubview(contentContainer)
        contentContainer.addSubview(tableView)
    }
    
    open override func constrainViews() {
        super.constrainViews()
        constrainContentContainer()
        constrainTableView()
    }
    
    open func initializeTableView() {
        tableView.separatorColor = .clear
    }
    
    open func constrainContentContainer() {
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: safeAreaContainer.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: safeAreaContainer.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: safeAreaContainer.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: safeAreaContainer.trailingAnchor),
            ])
    }
    
    private func constrainTableView() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            ])
    }
}
