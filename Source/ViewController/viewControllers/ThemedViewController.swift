//
//  ThemedViewController.swift
//  Nub
//
//  Created by Nick Bolton on 12/7/17.
//

import UIKit

open class ThemedViewController<T:UIView>: BaseViewController<T> {
    
    public override var isThemeable: Bool { return true }
    
    open override func viewDidLoad() {
        setupTheme()
        super.viewDidLoad()
    }
}
