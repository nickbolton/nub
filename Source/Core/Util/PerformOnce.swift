//
//  PerformOnce.swift
//  Nub
//
//  Created by Nick Bolton on 7/11/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit

public class PerformOnce: NSObject {

    private var didPerform = false
    
    func perform(_ handler: (()->Void)) {
        guard !didPerform else { return }
        handler()
        didPerform = true
    }
}
