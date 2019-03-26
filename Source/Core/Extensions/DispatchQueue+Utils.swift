//
//  DispatchQueue+Utils.swift
//  Nub
//
//  Created by Nick Bolton on 12/15/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//
import Foundation

extension DispatchQueue {
    
    public func wait(milliseconds: Int, onCompletion: @escaping DefaultHandler) {
        let seconds = Double(milliseconds) / 1000.0
        wait(timeInterval: seconds, onCompletion: onCompletion)
    }
    
    public func wait(timeInterval: TimeInterval, onCompletion: @escaping DefaultHandler) {
        asyncAfter(timeInterval: timeInterval, execute: onCompletion)
    }
    
    public func asyncAfter(timeInterval: TimeInterval, execute work: @escaping @convention(block) () -> Swift.Void) {
        let deadline = DispatchTime.now() + timeInterval
        asyncAfter(deadline: deadline, execute: work)
    }
    
    public func execute(minCompletionDelay minDelay: TimeInterval, execute work: @convention(block) () -> Swift.Void, onComplete: @escaping @convention(block) () -> Swift.Void) {
        let startTime = Date.timeIntervalSinceReferenceDate
        work()
        let elapsedTime = Date.timeIntervalSinceReferenceDate - startTime
        let delay = max(minDelay - elapsedTime, 0.0)
        asyncAfter(timeInterval: delay, execute: onComplete)
    }
    
    static public func mainSync(_ work: @escaping @convention(block) () -> Swift.Void) {
        if Thread.current.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }

    static public func mainAsync(_ work: @escaping @convention(block) () -> Swift.Void) {
        if Thread.current.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}

public struct MinDelayCompletor {
    let startTime: TimeInterval
    let minDelay: TimeInterval
    
    public init(startTime: TimeInterval = Date.timeIntervalSinceReferenceDate, minDelay: TimeInterval = 1.0) {
        self.startTime = startTime
        self.minDelay = minDelay
    }
    
    public func onSuccess(_ handler: DefaultHandler?) {
        guard let handler = handler else { return }
        let elapsedTime = Date.timeIntervalSinceReferenceDate - startTime
        let delay = max(minDelay - elapsedTime, 0.0)
        DispatchQueue.main.asyncAfter(timeInterval: delay, execute: handler)
    }
    
    public func onFailure(error: Error?, _ handler: DefaultFailureHandler?) {
        guard let handler = handler else { return }
        let elapsedTime = Date.timeIntervalSinceReferenceDate - startTime
        let delay = max(minDelay - elapsedTime, 0.0)
        DispatchQueue.main.asyncAfter(timeInterval: delay, execute: { handler(error) } )
    }
}
