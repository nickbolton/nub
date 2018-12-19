//
//  BackgroundTask.swift
//  Nub
//
//  Created by Nick Bolton on 5/6/18.
//

import UIKit

public class BackgroundTask: NSObject {
    private let application: UIApplication
    private var identifier = UIBackgroundTaskIdentifier.invalid
    
    init(application: UIApplication) {
        self.application = application
    }
    
    public static func run(application: UIApplication, handler: (BackgroundTask) -> ()) {
        let backgroundTask = BackgroundTask(application: application)
        backgroundTask.begin()
        handler(backgroundTask)
    }
    
    public func begin() {
        identifier = application.beginBackgroundTask {
            self.identifier = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    public func end() {
        if (identifier != UIBackgroundTaskIdentifier.invalid) {
            application.endBackgroundTask(identifier)
        }
        identifier = UIBackgroundTaskIdentifier.invalid
    }
}
