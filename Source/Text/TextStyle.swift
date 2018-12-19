//
//  TextStyle.swift
//  Nub
//
//  Created by Nick Bolton on 2/27/18.
//

import UIKit

public enum TargetTextType: Int {
    case label
    case field
    case view
}

public class TextStyle: NSObject {

    public var targetTextType = TargetTextType.label
    public var textDescriptors = [TextDescriptor]()
    
    public var isMixedStyle: Bool {
        var styleCount = 0
        for descriptor in textDescriptors {
            if descriptor.text.count > 0 {
                styleCount += 1
            }
        }
        return styleCount > 1
    }
    
    public var compositeText: String {
        var result = ""
        for descriptor in textDescriptors {
            result += descriptor.text
        }
        return result
    }
    
    public var attributedString: NSAttributedString {
        let result = NSMutableAttributedString()
        for descriptor in textDescriptors {
            let attributedString = descriptor.attributedString
            if attributedString.length > 0 {
                result.append(attributedString)
            }
        }
        return result
    }
    
    public var baselineAdjustment: CGFloat {
        var result: CGFloat = 0.0
        for descriptor in textDescriptors {
            result = max(result, descriptor.textAttributes.baselineOffset)
        }
        return result
    }
    
    public var maxAbsoluteBaselineAdjustment: CGFloat {
        var result: CGFloat = 0.0
        for descriptor in textDescriptors {
            result = max(result, abs(descriptor.textAttributes.baselineOffset))
        }
        return result
    }
    
    public var lineHeightMultiple: CGFloat {
        get { return textDescriptors.count > 0 ? textDescriptors.first!.textAttributes.lineHeightMultiple ?? 0.0 : 0.0 }
        set {
            for descriptor in textDescriptors {
                descriptor.textAttributes.lineHeightMultiple = newValue
            }
        }
    }

    public var textAlignment: TextAlignment {
        get { return textDescriptors.count > 0 ? textDescriptors.first!.textAttributes.textAlignment : .center }
        set {
            for descriptor in textDescriptors {
                descriptor.textAttributes.textAlignment = newValue
            }
        }
    }
    
    public var verticalAlignment: TextVerticalAlignment {
        get { return textDescriptors.count > 0 ? textDescriptors.first!.textAttributes.verticalAlignment : .center }
        set {
            for descriptor in textDescriptors {
                descriptor.textAttributes.verticalAlignment = newValue
            }
        }
    }
    
    public static var defaultStyle: TextStyle {
        let descriptor = TextDescriptor.defaultTextDescriptor
        return TextStyle(textDescriptors: [descriptor])
    }
    
    fileprivate let textDescriptorsKey = "textDescriptors"
    fileprivate let targetTextTypeKey = "targetTextType"
    
    public init(textDescriptors: [TextDescriptor], textAlignment: TextAlignment? = nil, verticalAlignment: TextVerticalAlignment? = nil) {
        self.textDescriptors = textDescriptors
        super.init()
        if let textAlignment = textAlignment {
            self.textAlignment = textAlignment
        }
        if let verticalAlignment = verticalAlignment {
            self.verticalAlignment = verticalAlignment
        }
    }

    public override func copy() -> Any {
        var textDescriptors = [TextDescriptor]()
        for descriptor in self.textDescriptors {
            textDescriptors.append(descriptor.copy() as! TextDescriptor)
        }
        let result = TextStyle(textDescriptors: textDescriptors)
        result.targetTextType = targetTextType
        return result
    }
    
    public func append(_ style: TextStyle) {
        textDescriptors.append(contentsOf: style.textDescriptors)
    }
    
    public func append(_ descriptors: [TextDescriptor]) {
        textDescriptors.append(contentsOf: descriptors)
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var result = [String: Any]()
        var descriptors = [[String: Any]]()
        for descriptor in textDescriptors {
            descriptors.append(descriptor.dictionaryRepresentation())
        }
        result[textDescriptorsKey] = descriptors
        return result
    }
    
    public func applyValues(_ values: [String]) {
        var values = values
        while (values.count > textDescriptors.count) {
            values.removeLast()
        }
        for idx in 0..<values.count {
            let descriptor = textDescriptors[idx]
            descriptor.text = values[idx]
            textDescriptors[idx] = descriptor
        }
    }
    
    public func textDescriptor(at location: Int) -> TextDescriptor? {
    
        var totalStringLength = 0
        var startPosition = 0
        var descriptorIndex = 0
        var matchedLastLocation = false
        
        for descriptor in textDescriptors {
            startPosition = totalStringLength
            totalStringLength += descriptor.text.count
            matchedLastLocation = location == totalStringLength
            if location >= startPosition && location < totalStringLength + 1 {
                break;
            }
            descriptorIndex += 1
        }
        
        // use the next descriptor if necessary
        if matchedLastLocation && descriptorIndex < textDescriptors.count - 1 {
            let nextDescriptor = textDescriptors[descriptorIndex+1]
            if nextDescriptor.text.count <= 0 {
                startPosition = totalStringLength
                descriptorIndex += 1
            }
        }
        
        if descriptorIndex >= self.textDescriptors.count {
            return nil
        }
        
        let result = textDescriptors[descriptorIndex];
        result.textRange = NSMakeRange(location - startPosition, 0)
        result.compositeTextRange = NSMakeRange(location, 0)
        return result
    }
    
    public func textDescriptor(in range: NSRange) -> [TextDescriptor] {
    
        if range.length == 0 {
            if let result = textDescriptor(at: range.location) {
                return [result]
            }
            return []
        }
        
        var totalStringLength = 0
        var startPosition = 0
        var lengthRemaining = range.length
        var descriptorIndex = 0
        var matchedLastLocation = false
        
        // find the first descriptor
        for descriptor in textDescriptors {
            startPosition = totalStringLength
            totalStringLength += descriptor.text.count
            matchedLastLocation = range.location == totalStringLength
            let targetStringLength = range.length > 0 ? totalStringLength : totalStringLength + 1
            if range.location >= startPosition && range.location < targetStringLength {
                break;
            }
            descriptorIndex += 1
        }
        
        if descriptorIndex >= self.textDescriptors.count {
            return []
        }
        
        // use the next descriptor if necessary
        if matchedLastLocation && range.length <= 0 && descriptorIndex < textDescriptors.count - 1 {
            let nextDescriptor = textDescriptors[descriptorIndex+1]
            if nextDescriptor.text.count <= 0 {
                startPosition = totalStringLength
                descriptorIndex += 1
            }
        }
        
        var result = [TextDescriptor]()
        let firstDescriptor = textDescriptors[descriptorIndex]
        
        var len = range.length
        if range.location - startPosition + range.length > firstDescriptor.text.count {
            len = range.location - startPosition + range.length - firstDescriptor.text.count
        }
        len = min(len, firstDescriptor.text.count)
        lengthRemaining -= len
        firstDescriptor.textRange = NSMakeRange(range.location - startPosition, len)
        firstDescriptor.compositeTextRange = NSMakeRange(range.location, len)
        result.append(firstDescriptor)
        
        if range.length <= 0 {
            return result
        }
        
        for idx in (descriptorIndex + 1)..<textDescriptors.count {
            guard lengthRemaining > 0 else { break }
            
            let textDescriptor = textDescriptors[idx]
            startPosition = totalStringLength
            totalStringLength += textDescriptor.text.count;
            if lengthRemaining > 0 {
                let len = min(lengthRemaining, textDescriptor.text.count)
                textDescriptor.textRange = NSMakeRange(0, len)
                textDescriptor.compositeTextRange = NSMakeRange(range.location, len)
                result.append(textDescriptor)
                lengthRemaining -= len
            }
        }
        
        return result
    }
    
    public func trueTextHeight(inBoundingWidth boundingWidth: CGFloat) -> CGFloat {
        let boundBy = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: self, textType: .label, boundBy: boundBy)
        let adjustedBoundBy = CGSize(width: boundingWidth + metrics.textMargins.left + metrics.textMargins.right, height: CGFloat.greatestFiniteMagnitude)
        return trueTextBounds(for: .label, boundBy: adjustedBoundBy).height
    }

    public func textViewHeight(inBoundingWidth boundingWidth: CGFloat) -> CGFloat {
        let boundBy = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: self, textType: .label, boundBy: boundBy)
        let adjustedBoundBy = CGSize(width: boundingWidth + metrics.textMargins.left + metrics.textMargins.right, height: CGFloat.greatestFiniteMagnitude)
        let result = textViewFrame(for: .label, boundBy: adjustedBoundBy, usePreciseTextAlignments: true).height
        return result
    }

    public func trueTextBounds(for textType: TargetTextType = .label, boundBy: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> CGRect {
        let (containerFrame, _) = trueTextBoundsAndViewFrame(for: textType, boundBy: boundBy, usePreciseTextAlignments: true)
        return containerFrame
    }
    
    public func textViewFrame(for textType: TargetTextType = .label, boundBy: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), usePreciseTextAlignments: Bool = false, containerSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> CGRect {
        let (_, textFrame) = trueTextBoundsAndViewFrame(for: textType, boundBy: boundBy, usePreciseTextAlignments: usePreciseTextAlignments, containerSize: containerSize)
        return textFrame
    }
    
    public func trueTextBoundsAndViewFrame(for textType: TargetTextType, boundBy boundByIn: CGSize, usePreciseTextAlignments: Bool, containerSize: CGSize = .zero) -> (CGRect, CGRect) {

        let boundBy = CGSize(width: boundByIn.width > 0 ? boundByIn.width : CGFloat.greatestFiniteMagnitude, height: boundByIn.height > 0 ? boundByIn.height : CGFloat.greatestFiniteMagnitude)
        let metrics = TextMetricsCache.shared.textMetrics(for: self, textType: textType, boundBy: boundBy)
                
        var size = CGSize.zero
        if usePreciseTextAlignments {
            size = metrics.textSize
        } else {
            let options = NSStringDrawingOptions.usesLineFragmentOrigin.union(.usesFontLeading)
            let rect = attributedString.boundingRect(with: boundBy, options: options, context: nil)
            size = CGSize(width: rect.width.halfPointCeilValue, height: rect.height.halfPointCeilValue)
        }
        
        let width = boundBy.width < CGFloat.greatestFiniteMagnitude ? boundBy.width: size.width
        let height = (boundBy.height < CGFloat.greatestFiniteMagnitude ? boundBy.height: size.height) - baselineAdjustment
        
        size = CGSize(width: width.halfPointCeilValue, height: height.halfPointCeilValue)
        
        let horizontalPadding = metrics.textMargins.left + metrics.textMargins.right
        let verticalPadding = metrics.textMargins.top + metrics.textMargins.bottom
        
        var containerFrame = CGRect.zero
        containerFrame.size = size
        if usePreciseTextAlignments {
            containerFrame.size.width -= horizontalPadding
            containerFrame.size.height -= verticalPadding
        }
        containerFrame.size.height = containerFrame.height.halfPointRoundValue
        
        var textFrame = containerFrame
        
        if usePreciseTextAlignments {
            textFrame = CGRect(x: -metrics.textMargins.left, y: 0.0, width: size.width, height: size.height)
            if textAlignment == .center || textAlignment == .justified {
                textFrame.origin.x = -(metrics.textMargins.left + metrics.textMargins.right) / 2.0
            }
        }
        
        let heightDiff = (containerSize.height - size.height).halfPointRoundValue
        
        switch verticalAlignment {
        case .top:
            if usePreciseTextAlignments {
                textFrame.origin.y -= metrics.textMargins.top
            }
        case .center:
            textFrame.origin.y += heightDiff / 2.0
            if usePreciseTextAlignments {
                textFrame.origin.y += (-metrics.textMargins.top + metrics.textMargins.bottom) / 2.0
            }
        case .bottom:
            textFrame.origin.y += heightDiff
            if usePreciseTextAlignments {
                textFrame.origin.y += metrics.textMargins.bottom
            }
        }
        
        return (containerFrame, textFrame)
    }
}
