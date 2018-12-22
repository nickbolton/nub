//
//  TextAttributes.swift
//  Nub
//
//  Created by Nick Bolton on 12/31/17.
//

import UIKit
typealias LineBreakModeType = Int

public enum SystemFontWeight: String {
    case regular
    case italic
    case ultralight
    case ultralightItalic
    case thin
    case thinItalic
    case light
    case lightItalic
    case medium
    case mediumItalic
    case semibold
    case semiboldItalic
    case bold
    case boldItalic
    case heavy
    case heavyItalic
    case black
    case blackItalic

    private static let weightMap: [SystemFontWeight: UIFont.Weight] = [
        .regular: .regular,
        .italic: .regular,
        .ultralight: .ultraLight,
        .ultralightItalic: .ultraLight,
        .thin: .thin,
        .thinItalic: .thin,
        .light: .light,
        .lightItalic: .light,
        .medium: .medium,
        .mediumItalic: .medium,
        .semibold: .semibold,
        .semiboldItalic: .semibold,
        .bold: .bold,
        .boldItalic: .bold,
        .heavy: .heavy,
        .heavyItalic: .heavy,
        .black: .black,
        .blackItalic: .black,
        ]

    public var fontWeight: UIFont.Weight {
        return SystemFontWeight.weightMap[self]!
    }
    
    public var isItalic: Bool {
        return self == .italic
            || self == .ultralightItalic
            || self == .thinItalic
            || self == .lightItalic
            || self == .mediumItalic
            || self == .semiboldItalic
            || self == .boldItalic
            || self == .heavyItalic
            || self == .blackItalic
    }
}

public enum TextAlignment : Int {
    case left = 0// Visually left aligned
    case right // Visually centered
    case center // Visually right aligned
    case justified // Fully-justified. The last line in a paragraph is natural-aligned.
    case natural // Indicates the default alignment for script
    
    func nativeAlignment() -> NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justified:
            return .justified
        case .natural:
            return .natural
        }
    }
}

public enum TextVerticalAlignment: Int {
    case top = 0
    case center
    case bottom
}

public struct TextAttributes {
    
    public var font: UIFont
    public var kerning: CGFloat
    public var lineHeightMultiple: CGFloat?
    public var paragraphSpacing: CGFloat
    public var baselineOffset: CGFloat
    public var minimumLineHeight: CGFloat
    public var maximumLineHeight: CGFloat
    public var textAlignment: TextAlignment
    public var verticalAlignment: TextVerticalAlignment
    public var lineBreakMode: NSLineBreakMode
    public var underlineStyle: Int
    public var isStrikeThrough: Bool
    public var textColor: UIColor
    
    public static let defaultFontSize: CGFloat = 17.0
    
    public var cacheKey: String {
        return "\(font.fontName)|\(font.pointSize)|\(lineHeightMultiple ?? 0.0)|\(minimumLineHeight)|\(maximumLineHeight)|\(kerning)|\(paragraphSpacing)"
    }
    
    public init() {
        self.font = UIFont.systemFont(ofSize: TextAttributes.defaultFontSize)
        self.kerning = 0.0
        self.paragraphSpacing = 0.0
        self.baselineOffset = 0.0
        self.textAlignment = .left
        self.verticalAlignment = .center
        self.lineBreakMode = .byWordWrapping
        self.underlineStyle = 0
        self.isStrikeThrough = false
        self.textColor = .black
        self.minimumLineHeight = 0.0
        self.maximumLineHeight = 0.0
    }
    
    public init(font: UIFont,
                textColor: UIColor = .clear,
                lineHeightMultiple: CGFloat? = nil,
                minimumLineHeight: CGFloat = 0.0,
                maximumLineHeight: CGFloat = 0.0,
                kerning: CGFloat = 0.0,
                paragraphSpacing: CGFloat = 0.0,
                baselineOffset: CGFloat = 0.0,
                textAlignment: TextAlignment = .left,
                verticalAlignment: TextVerticalAlignment = .center,
                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                underlineStyle: Int = 0,
                isStrikeThrough: Bool = false) {
        self.font = font
        self.kerning = kerning
        self.lineHeightMultiple = lineHeightMultiple
        self.paragraphSpacing = paragraphSpacing
        self.baselineOffset = baselineOffset
        self.textAlignment = textAlignment
        self.verticalAlignment = verticalAlignment
        self.lineBreakMode = lineBreakMode
        self.underlineStyle = underlineStyle
        self.isStrikeThrough = isStrikeThrough
        self.textColor = textColor
        self.minimumLineHeight = minimumLineHeight
        self.maximumLineHeight = maximumLineHeight
    }
    
    public init(systemFontWeight: SystemFontWeight,
                pointSize: CGFloat,
                textColor: UIColor = .clear,
                lineHeightMultiple: CGFloat? = nil,
                minimumLineHeight: CGFloat = 0.0,
                maximumLineHeight: CGFloat = 0.0,
                kerning: CGFloat = 0.0,
                paragraphSpacing: CGFloat = 0.0,
                baselineOffset: CGFloat = 0.0,
                textAlignment: TextAlignment = .left,
                verticalAlignment: TextVerticalAlignment = .center,
                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                underlineStyle: Int = 0,
                isStrikeThrough: Bool = false) {
        self.font = UIFont.systemFont(systemFontWeight: systemFontWeight, pointSize: pointSize)
        self.kerning = kerning
        self.lineHeightMultiple = lineHeightMultiple
        self.paragraphSpacing = paragraphSpacing
        self.baselineOffset = baselineOffset
        self.textAlignment = textAlignment
        self.verticalAlignment = verticalAlignment
        self.lineBreakMode = lineBreakMode
        self.underlineStyle = underlineStyle
        self.isStrikeThrough = isStrikeThrough
        self.textColor = textColor
        self.minimumLineHeight = minimumLineHeight
        self.maximumLineHeight = maximumLineHeight
    }
    
    public var attributes: [NSAttributedString.Key: Any] {
        let font = self.font
        var result = [NSAttributedString.Key: Any]()
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = textAlignment.nativeAlignment()
        paragraphStyle.paragraphSpacing = paragraphSpacing
        
        if let lineHeightMultiple = lineHeightMultiple {
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
        }
        paragraphStyle.maximumLineHeight = maximumLineHeight
        paragraphStyle.minimumLineHeight = minimumLineHeight
        
        paragraphStyle.allowsDefaultTighteningForTruncation = lineBreakMode != .byWordWrapping && lineBreakMode != .byCharWrapping && lineBreakMode != .byClipping
        
        result[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        result[NSAttributedString.Key.kern] = kerning
        result[NSAttributedString.Key.underlineStyle] = underlineStyle
        
        if isStrikeThrough {
            result[NSAttributedString.Key.strikethroughStyle] = true
        }
        
        result[NSAttributedString.Key.baselineOffset] = baselineOffset
        
        result[NSAttributedString.Key.font] = font
        result[NSAttributedString.Key.foregroundColor] = textColor
        
        return result
    }
}

