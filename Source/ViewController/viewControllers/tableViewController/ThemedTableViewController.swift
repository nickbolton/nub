//
//  ThemedTableViewController.swift
//  Nub
//
//  Created by Nick Bolton on 12/7/17.
//

import UIKit

open class ThemedTableViewController<VT:TableRootView, DT:NSObject>: TableViewController<VT, DT> {
    open override func viewDidLoad() {
        setupTheme()
        super.viewDidLoad()
    }
}
