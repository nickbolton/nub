//
//  UIImage+Utils.swift
//  Nub
//
//  Created by Nick Bolton on 3/15/19.
//

import UIKit

public extension UIImage {
    
    public func resize(size: CGSize) -> UIImage {
        guard let cgImage = cgImage else { return self }
        let newRect = CGRect(origin: .zero, size: size).integral
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.interpolationQuality = .high
        let flipVertical = CGAffineTransform(scaleX: 1.0, y: -1.0)
        let translate = CGAffineTransform(translationX: 0.0, y: -size.height)
        context.concatenate(flipVertical)
        context.concatenate(translate)
        context.draw(cgImage, in: newRect)
        guard let newImageRef = context.makeImage() else { return self }
        let result = UIImage(cgImage: newImageRef)
        UIGraphicsEndImageContext()
        return result
    }
}
