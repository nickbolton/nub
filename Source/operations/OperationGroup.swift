//
//  OperationGroup.swift
//  Nub
//
//  Created by Nick Bolton on 6/26/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit

public class OperationGroup: NSObject {

    private var activeLocks = Set<NSConditionLock>()
    private var backgroundTask = UIBackgroundTaskIdentifier.invalid
    private var operations = [Operation]()
    private var isCancelled = false
    
    var useConcurrentQueue = true

    public func execute<T:Operation>(operations: [T], onSuccess: (([T])->Void)? = nil, onFailure: ((Error?)->Void)? = nil) {
        
        self.operations = operations
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let `self` = self else { return }
            if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
                let error = NSError(domain: "Traits", code: -1000, userInfo: [NSLocalizedDescriptionKey: "Background task timed out"])
                onFailure?(error)
            }
            
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid;
        }
        
        let completeTask = { [weak self] in
            guard let `self` = self else { return }
            if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                onFailure?(nil)
                return
            }
            self.doExecuteOperations(operations, onSuccess: { operations in
                completeTask()
                onSuccess?(operations)
            }) { error in
                completeTask()
                onFailure?(error)
            }
        }
    }
    
    public func cancel() {
        isCancelled = true
        for operation in operations {
            operation.cancel()
        }
    }
    
    private func doExecuteOperations<T:Operation>(_ operations: [T], onSuccess: (([T])->Void)? = nil, onFailure: ((Error?)->Void)? = nil) {

        let lock = NSConditionLock(condition: operations.count)
        var firstError: Error?
        var didError = false
        isCancelled = false
        
        self.activeLocks.insert(lock)
        
        let localSuccessHandler = {
            lock.lock()
            lock.unlock(withCondition: lock.condition - 1)
        }
        
        let localFailureHandler: ((Error?)->Void) = { error in
            lock.lock()
            didError = true
            if firstError == nil {
                firstError = error
            }
            lock.unlock(withCondition: lock.condition - 1)
        }
        
        DispatchQueue.global().async {
            for operation in operations {
                if let retryingOperation = operation as? RetryingOperation {
                    retryingOperation.successHandler = localSuccessHandler
                    retryingOperation.failureHandler = localFailureHandler
                } else {
                    operation.completionBlock = localSuccessHandler
                }
                if self.useConcurrentQueue {
                    OperationsManager.shared.concurrentlyQueueOperation(operation)
                } else {
                    OperationsManager.shared.concurrentlyQueueOperation(operation)
                }
            }
            
            lock.lock(whenCondition: 0)
            lock.unlock()
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.activeLocks.remove(lock)
                if !self.isCancelled {
                    if didError {
                        onFailure?(firstError)
                    } else {
                        onSuccess?(operations)
                    }
                }
            }
        }
    }
}
