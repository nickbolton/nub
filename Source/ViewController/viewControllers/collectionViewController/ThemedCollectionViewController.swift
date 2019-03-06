//
//  ThemedCollectionViewController.swift
//  Nub
//
//  Created by Nick Bolton on 12/7/17.
//

import UIKit

open class ThemedCollectionViewController<VT:CollectionRootView>: CollectionViewController<VT> {
    open override func viewDidLoad() {
        setupTheme()
        super.viewDidLoad()
    }
}
