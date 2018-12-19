//
//  InteractionGuard.swift
//  Nub
//
//  Created by Nick Bolton on 7/10/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit

public class InteractionGuard: NSObject {

    private var semephore = false
    
    public func perform(_ handler: DefaultHandler) {
        guard !semephore else { return }
        semephore = true
        handler()
        DispatchQueue.main.asyncAfter(timeInterval: 0.2) { [weak self] in self?.semephore = false }
    }
}
