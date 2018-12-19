//
//  TimeKeeper.swift
//  Nub
//
//  Created by Nick Bolton on 11/16/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//

import UIKit

public class TimeKeeper: NSObject {

    static public let shared = TimeKeeper()
    private override init() {}
    
    private var lastServerTimeUpdate: TimeInterval = 0.0
    
    public var serverTime: Date? {
        didSet {
            lastServerTimeUpdate = Date.timeIntervalSinceReferenceDate
        }
    }
    
    public var currentTime: Date {
        get {
            let now = Date()
            if let time = serverTime {
                if lastServerTimeUpdate != 0.0 {
                    let elapsedTime = now.timeIntervalSinceReferenceDate - lastServerTimeUpdate
                    return time.addingTimeInterval(elapsedTime)
                } else {
                    return time
                }
            }
            return now
        }
    }
}
