//
//  BaseOperation.swift
//  Nub
//
//  Created by Nick Bolton on 5/3/17.
//  Copyright © 2017 Pixelbleed, LLC. All rights reserved.
//

import UIKit

open class BaseOperation: Operation {

    open override func main() {
        guard !isCancelled else { return }
        protectedMain()
    }
    
    open func protectedMain() {
        // abstract
    }
}
