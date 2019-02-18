//
//  TextDescriptor.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#else
import Cocoa
#endif

public class TextDescriptor: NSObject {
    
    public var text = ""
    public var textAttributes = TextAttributes()
    public var textRange = NSMakeRange(0, 0)
    public var compositeTextRange = NSMakeRange(0, 0)
    
    fileprivate let textKey = "text"
    fileprivate let textAttributesKey = "textAttributes"
    
    public static var defaultTextDescriptor: TextDescriptor { return TextDescriptor(text: "") }
    
    public var attributedString: NSAttributedString { return NSAttributedString(string: text, attributes: textAttributes.attributes) }
    public var attributes: [NSAttributedString.Key: Any] { return textAttributes.attributes }
    public var typingAttributes: [String: Any] {
        var result = [String: Any]()
        for (key, value) in attributes {
            result[key.rawValue] = value
        }
        return result
    }
    
    public init(text: String) {
        self.text = text
    }
    
    public init(text: String = "",
                font: UIFont,
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
        self.text = text
        self.textAttributes = TextAttributes(font: font, textColor: textColor, lineHeightMultiple: lineHeightMultiple, minimumLineHeight: minimumLineHeight, maximumLineHeight: maximumLineHeight, kerning: kerning, paragraphSpacing: paragraphSpacing, baselineOffset: baselineOffset, textAlignment: textAlignment, verticalAlignment: verticalAlignment, lineBreakMode: lineBreakMode, underlineStyle: underlineStyle, isStrikeThrough: isStrikeThrough)
    }
    
    public init(text: String = "",
                font: UIFont,
                textColor: UIColor = .clear,
                lineHeight: CGFloat = 0.0,
                kerning: CGFloat = 0.0,
                paragraphSpacing: CGFloat = 0.0,
                baselineOffset: CGFloat = 0.0,
                textAlignment: TextAlignment = .left,
                verticalAlignment: TextVerticalAlignment = .center,
                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                underlineStyle: Int = 0,
                isStrikeThrough: Bool = false) {
        self.text = text
        self.textAttributes = TextAttributes(font: font, textColor: textColor, lineHeight: lineHeight, kerning: kerning, paragraphSpacing: paragraphSpacing, baselineOffset: baselineOffset, textAlignment: textAlignment, verticalAlignment: verticalAlignment, lineBreakMode: lineBreakMode, underlineStyle: underlineStyle, isStrikeThrough: isStrikeThrough)
    }
    
    public init(text: String = "",
                systemFontWeight: SystemFontWeight,
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
        self.text = text
        self.textAttributes = TextAttributes(systemFontWeight: systemFontWeight, pointSize: pointSize, textColor: textColor, lineHeightMultiple: lineHeightMultiple, minimumLineHeight: minimumLineHeight, maximumLineHeight: maximumLineHeight, kerning: kerning, paragraphSpacing: paragraphSpacing, baselineOffset: baselineOffset, textAlignment: textAlignment, verticalAlignment: verticalAlignment, lineBreakMode: lineBreakMode, underlineStyle: underlineStyle, isStrikeThrough: isStrikeThrough)
    }
    
    public init(text: String = "",
                attributes: TextAttributes) {
        self.text = text
        self.textAttributes = attributes
    }
    
    public override func copy() -> Any {
        let result = TextDescriptor(text: text)
        result.textAttributes = textAttributes
        return result
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        let textAttributes = self.textAttributes
        var dict = [String: Any]()
        dict[textAttributesKey] = textAttributes
        dict[textKey] = text
        return dict
    }
}
