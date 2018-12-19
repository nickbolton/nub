//
//  ThemedTableCell.swift
//  Nub
//
//  Created by Nick Bolton on 6/18/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit

open class ThemedTableCell: BaseTableViewCell, ThemeableView {
    
    public let isThemeable = true

    open override func didInit() {
        super.didInit()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeChanged),
                                               name: NSNotification.Name.ThemeChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangePreferredContentSize),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    // MARK: Notifications
    
    @objc internal func themeChanged() {
        updateTheme()
    }
    
    @objc internal func didChangePreferredContentSize(_ noti: Notification) {
        if let setting = noti.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as? UIContentSizeCategory {
            ThemeManager.shared.contentSizeCategory = setting
        }
        preferredContentSizeChanged()
    }
    
    // MARK: Theme
    
    open func setupTheme() {
    }
    
    open func updateTheme() {
        let theme: Theme = ThemeManager.shared.currentTheme()
        backgroundColor = theme.defaultBackgroundColor
        contentView.backgroundColor = theme.defaultBackgroundColor
        for child in subviews {
            if let view = child as? ThemeableView {
                view.updateTheme()
            }
        }
        for child in contentView.subviews {
            if let view = child as? ThemeableView {
                view.updateTheme()
            }
        }
    }
    
    open func preferredContentSizeChanged() {
    }
}
