//
//  ThemeManager.swift
//  Nub
//
//  Created by Nick Bolton on 10/29/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit

extension Notification.Name {
    static public let ThemeChanged = Notification.Name("ThemeChanged")
}

public protocol Theme {
    var name: String { get }
    var defaultTextColor: UIColor { get }
    var defaultBackgroundColor: UIColor { get }
    var greyTextColor: UIColor { get }
    var dividerColor: UIColor { get }
    var appTint: UIColor { get }
    var defaultAnimationDuration: TimeInterval { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var isStatusBarHidden: Bool { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var fontScale: CGFloat { get set }
    var headlineFont: UIFont { get }
    var bodyFont: UIFont { get }
    func scaledValue(_ value: CGFloat) -> CGFloat
}

open class DefaultTheme: Theme {
    public var fontScale: CGFloat = 1.0
    public var name: String = ""
    public var isStatusBarHidden = false
    public var defaultTextColor: UIColor = UIColor.white.color(withAlpha: 0.85)
    public var defaultBackgroundColor: UIColor = .black
    public var greyTextColor: UIColor = UIColor(hex: 0x808080).color(withAlpha: 0.6)
    public var dividerColor: UIColor = UIColor(hex: 0x808080).color(withAlpha: 0.2)
    public var appTint: UIColor = UIColor(hex: 0x008DFA)
    public var defaultAnimationDuration: TimeInterval { return 0.3 }
    public var statusBarStyle: UIStatusBarStyle = .default
    public var keyboardAppearance: UIKeyboardAppearance = .light

    public var headlineFont: UIFont { return UIFont.boldSystemFont(ofSize: scaledValue(22.0)) }
    public var bodyFont: UIFont { return UIFont.systemFont(ofSize: scaledValue(16.0)) }
    
    public func scaledValue(_ value: CGFloat) -> CGFloat {
        return round((value * fontScale) * 2.0) / 2.0
    }
}

open class DefaultLightTheme: DefaultTheme {
    public override init() {
        super.init()
        self.name = ThemeManager.defaultLightThemeName
        self.defaultTextColor = .black
        self.defaultBackgroundColor = .white
        self.appTint = UIColor(hex: 0x008DFA)
        self.dividerColor = UIColor(hex: 0x808080).color(withAlpha: 0.1)
        self.statusBarStyle = .default
        self.keyboardAppearance = .light
    }
}

open class DefaultDarkTheme: DefaultTheme {
    public override init() {
        super.init()
        self.name = ThemeManager.defaultDarkThemeName
        self.defaultTextColor = UIColor.white.color(withAlpha: 0.85)
        self.defaultBackgroundColor = .black
        self.appTint = UIColor(hex: 0x008DFA)
        self.dividerColor = UIColor(hex: 0x808080).color(withAlpha: 0.2)
        self.statusBarStyle = .lightContent
        self.keyboardAppearance = .dark
    }
}

public class ThemeManager: NSObject {
    
    static public let defaultLightThemeName = "ThemeManager.defaultLight"
    static public let defaultDarkThemeName = "ThemeManager.defaultDark"

    static public let shared = ThemeManager()
    private override init() {}
        
    private var themes = [String: Theme]()
    private (set) public var selectedName: String = ""
    
    public func currentTheme() -> Theme {
        return themes[selectedName] ?? DefaultLightTheme()
    }
    
    public func selectedTheme<T>() -> T? {
        return themes[selectedName] as? T
    }
    
    var contentSizeCategory: UIContentSizeCategory = UIContentSizeCategory.large {
        didSet {
            var scale = 0
            let factor: CGFloat = 0.075
            switch contentSizeCategory {
            case UIContentSizeCategory.extraSmall:
                scale = -3
            case UIContentSizeCategory.small:
                scale = -2
            case UIContentSizeCategory.medium:
                scale = -1
            case UIContentSizeCategory.large:
                scale = 0
            case UIContentSizeCategory.extraLarge:
                scale = 1
            case UIContentSizeCategory.extraExtraLarge:
                scale = 2
            case UIContentSizeCategory.extraExtraExtraLarge:
                scale = 3
            case UIContentSizeCategory.accessibilityMedium:
                scale = 4
            case UIContentSizeCategory.accessibilityLarge:
                scale = 5
            case UIContentSizeCategory.accessibilityExtraLarge:
                scale = 6
            case UIContentSizeCategory.accessibilityExtraExtraLarge:
                scale = 7
            case UIContentSizeCategory.accessibilityExtraExtraExtraLarge:
                scale = 8
            default:
                scale = 0
            }
            
            var fontScale: CGFloat = 1.0
            
            if scale > 0 {
                for _ in 1...scale {
                    fontScale += factor
                }
            } else if scale < 0 {
                for _ in scale..<0 {
                    fontScale -= factor
                }
            }
            
            for theme in themes.values {
                var updatedTheme = theme
                updatedTheme.fontScale = fontScale
                themes[updatedTheme.name] = updatedTheme
            }
        }
    }

    public func registerTheme(_ theme: Theme) {
        themes[theme.name] = theme
        if selectedName.length <= 0 {
            selectThemeNamed(theme.name)
        }
    }
    
    public func selectThemeNamed(_ name: String) {
        guard themes[name] != nil else { return }
        let changed = selectedName != name
        selectedName = name
        contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        if changed {
            NotificationCenter.default.post(name: Notification.Name.ThemeChanged, object: self)
        }
    }
}
