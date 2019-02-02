//
//  TableRootView.swift
//  Nub
//
//  Created by Nick Bolton on 9/2/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

open class TableRootView: BaseView {

    public let tableView = UITableView()
    
    public var anchorToSafeArea = true

    // MARK: View Hierarchy Construction
    
    open override func initializeViews() {
        super.initializeViews()
        initializeTableView()
    }
    
    open override func assembleViews() {
        super.assembleViews()
        addSubview(tableView)
    }
    
    open override func constrainViews() {
        super.constrainViews()
        constrainTableView()
    }
    
    open func initializeTableView() {
        tableView.separatorColor = .clear
    }
        
    private func constrainTableView() {
        if anchorToSafeArea {
            NSLayoutConstraint.activate([
                tableView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
                tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                ])
        } else {
            tableView.expand()
        }
    }
}
