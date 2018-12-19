//
//  Platform.swift
//  Nub
//
//  Created by Nick Bolton on 8/26/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

public struct Platform {
    public static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
