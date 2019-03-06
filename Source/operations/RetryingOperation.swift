//
//  RetryingOperation.swift
//  Nub
//
//  Created by Nick Bolton on 5/3/17.
//  Copyright © 2017 Bedrock. All rights reserved.
//

import UIKit

public typealias RetryingSuccessHandler = ((DefaultHandler?) -> Void)
public typealias RetryingFailureHandler = ((Error?, Bool, Bool) -> Void)

open class RetryingOperation: Operation {
    
    public var userInfo: Any?
    
    open override var isAsynchronous: Bool { return true }
    public var returnOnMainThread = true
    public var successHandler: DefaultHandler?
    public var failureHandler: DefaultFailureHandler?
    open var minimumExecutionTime: TimeInterval { return 0.0 }
    public var maxRetries = 2
    
    private var error: Error?
    private var succeeded = false
    private var retryCount = 0
    private var startTime: TimeInterval = 0.0
    
    private var _isExecuting = false
    open override var isExecuting: Bool {
        get { return _isExecuting }
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _isFinished = false
    open override var isFinished: Bool {
        get { return _isFinished }
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    open var isRetrying: Bool {
        return retryCount > 0
    }
    
    public init(maxRetries: Int = 2, userInfo: Any? = nil) {
        super.init()
        self.maxRetries = maxRetries
        self.userInfo = userInfo
    }
    
    private func decrementRetryCount() {
        retryCount = max(retryCount - 1, 0)
    }
    
    open override func start() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.start()
            }
            return
        }
        
        guard !isCancelled else {
            finish(nil)
            return
        }
        
        startTime = Date.timeIntervalSinceReferenceDate
        retryCount = 0
        succeeded = false
        
        let (ok, error) = shouldExecuteOperation()
        if ok {
            isExecuting = true
            executeMainWithRetryCount()
        } else {
            self.error = error
            finish(nil)
        }
    }
    
    open func protectedMain(onSuccess: @escaping RetryingSuccessHandler, onFailure: @escaping RetryingFailureHandler) {
    }
    
    open func shouldExecuteOperation() -> (Bool, Error?) {
        return (true, nil)
    }
    
    private func executeMainWithRetryCount() {
        
        guard retryCount < maxRetries else {
            callFailureHandler()
            return;
        }
        
        error = nil;
        
        protectedMain(onSuccess: { [weak self] onSuccess in
            self?.succeeded = true
            self?.finish(onSuccess)
            }, onFailure: { [weak self] (error, shouldRetry, immediateRetry) in
                self?.error = error
                self?.retryCount += 1
                if shouldRetry {
                    let delay = immediateRetry ? 0.0 : Double.random(min: 3.0, max: 5.0)
                    DispatchQueue.main.asyncAfter(timeInterval: delay) {
                        self?.executeMainWithRetryCount()
                    }
                } else {
                    self?.callFailureHandler()
                }
        })
    }
    
    private func finish(_ onSuccess: DefaultHandler?) {
        isExecuting = false
        isFinished = true
        
        if returnOnMainThread && !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.callCompletionHandler(onSuccess)
            }
        } else {
            callCompletionHandler(onSuccess)
        }
    }
    
    private func callCompletionHandler(_ onSuccess: DefaultHandler?) {
        if succeeded {
            callSuccessHandler(onSuccess)
        } else {
            callFailureHandler()
        }
    }
    
    private func callSuccessHandler(_ onSuccess: DefaultHandler?) {
        let endTime = Date.timeIntervalSinceReferenceDate
        let duration = endTime - startTime
        let remainingTime = max(minimumExecutionTime - duration, 0.0)
        let successHandler = self.successHandler
        if remainingTime > 0.0 {
            DispatchQueue.main.asyncAfter(timeInterval: remainingTime) {
                onSuccess?()
                successHandler?()
            }
        } else {
            onSuccess?()
            successHandler?()
        }
    }
    
    private func callFailureHandler() {
        guard !isFinished else { return }
        isExecuting = false
        isFinished = true
        failureHandler?(error)
    }
}
