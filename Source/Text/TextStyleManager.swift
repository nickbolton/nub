//
//  TextStyleManager.swift
//  Nub
//
//  Created by Nick Bolton on 8/21/18.
//

import UIKit

public class TextStyleManager: NSObject {

    static public let shared = TextStyleManager()
    private override init() {}
    
    private var styles = [String: TextStyle]()
    
    public func registerStyle(_ style: TextStyle, withName name: String) {
        styles[name] = style
    }
    
    public func style(withName name: String) -> TextStyle? {
        return styles[name]
    }
}
