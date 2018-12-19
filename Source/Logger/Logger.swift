//
//  Logging.swift
//  Nub
//
//  Created by Nick Bolton on 11/14/16.
//  Copyright © 2016 Pixelbleed, LLC. All rights reserved.
//

import UIKit
import SwiftyBeaver

public class Logger: NSObject {
    
    static public let shared = Logger()
    
    public var logLevel: SwiftyBeaver.Level = .error
    
    private override init() {
        let console = ConsoleDestination()
        console.minLevel = .debug
        console.format = "$DHH:mm:ss$d $L $M"
        SwiftyBeaver.self.addDestination(console)
        #if DEBUG
            logLevel = .verbose
        #endif
    }
    
    /// log something generally unimportant (lowest priority)
    public func verbose(_ message: @autoclosure () -> Any) {
        if logLevel.rawValue <= SwiftyBeaver.Level.verbose.rawValue {
            SwiftyBeaver.self.verbose(message)
        }
    }
    
    /// log something which help during debugging (low priority)
    public func debug(_ message: @autoclosure () -> Any) {
        if logLevel.rawValue <= SwiftyBeaver.Level.debug.rawValue {
            SwiftyBeaver.self.debug(message)
        }
    }
    
    /// log something which you are really interested but which is not an issue or error (normal priority)
    public func info(_ message: @autoclosure () -> Any) {
        if logLevel.rawValue <= SwiftyBeaver.Level.info.rawValue {
            SwiftyBeaver.self.info(message)
        }
    }
    
    /// log something which may cause big trouble soon (high priority)
    public func warning(_ message: @autoclosure () -> Any) {
        if logLevel.rawValue <= SwiftyBeaver.Level.warning.rawValue {
            SwiftyBeaver.self.warning(message)
        }
    }
    
    /// log something which will keep you awake at night (highest priority)
    public func error(_ message: @autoclosure () -> Any) {
        if logLevel.rawValue <= SwiftyBeaver.Level.error.rawValue {
            SwiftyBeaver.self.error(message)
        }
    }
}
