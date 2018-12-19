//
//  Locker.swift
//  Nub
//
//  Created by Nick Bolton on 8/15/16.
//  Copyright © 2016 Pixelbleed LLC. All rights reserved.
//

import UIKit
import FXKeychain

public protocol Locker {
    var name: String { get }
    func wipeData()
}

public class LockerManager: NSObject {
    static public let shared = LockerManager()
    private override init() {
        super.init()
        registerLocker(DefaultLocker())
    }
    
    public var defaultLocker: DefaultLocker { return lockerNamed(_defaultLockerName) as! DefaultLocker }
    
    private var lockers = [String: Locker]()
    
    public func registerLocker(_ locker: Locker) {
        lockers[locker.name] = locker
    }
    
    public func lockerNamed(_ name: String) -> Locker? {
        return lockers[name]
    }
    
    public func wipeData() {
        for locker in lockers.values {
            locker.wipeData()
        }
    }
}

fileprivate let _defaultLockerName = "LockerManager.default"

open class BaseLocker: NSObject, Locker {
    public var name: String
    public let keychain: FXKeychain
    private (set) var iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore()

    required public init(name: String) {
        let bundleID: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as! String;
        keychain = FXKeychain(service: bundleID, accessGroup: nil)
        self.name = name
        super.init()
        iCloudKeyStore.synchronize()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(noti:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    private var needsICloudSync = false
    @objc func applicationDidEnterBackground(noti: NSNotification) {
        needsICloudSync = true
    }
    
    open func wipeData() {
    }
    
    // MARK: Helpers
    
    public func syncICloudIfNecessary() {
        if needsICloudSync {
            iCloudKeyStore.synchronize()
        }
    }
    
    public func iCloudObject(forKey: String) -> Any? {
        syncICloudIfNecessary()
        if let result = iCloudKeyStore.object(forKey: forKey) {
            return result
        }
        return UserDefaults.standard.object(forKey: forKey)
    }
    
    public func setICloudObject(_ object: Any?, forKey: String) {
        iCloudKeyStore.set(object, forKey: forKey)
        UserDefaults.standard.set(object, forKey: forKey)
        iCloudKeyStore.synchronize()
        UserDefaults.standard.synchronize()
    }
    
    public func setKeychainObject(_ object: Any?, forKey: String) {
        if Platform.isSimulator {
            UserDefaults.standard.set(object, forKey: forKey)
            UserDefaults.standard.synchronize()
        } else {
            keychain.setObject(object, forKey: forKey)
        }
    }
    
    public func keychainObject(forKey: String) -> Any? {
        if Platform.isSimulator {
            return UserDefaults.standard.object(forKey: forKey)
        }
        return keychain.object(forKey: forKey)
    }
}

public class DefaultLocker: BaseLocker {
    
    init() {
        super.init(name: _defaultLockerName)
    }
    
    public required init(name: String) {
        super.init(name: name)
    }
    
    private let hasLaunchedAppKey = "hasLaunchedApp"
    public var hasLaunchedApp: Bool {
        get { return UserDefaults.standard.bool(forKey: hasLaunchedAppKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: hasLaunchedAppKey)
            DispatchQueue.global().async { UserDefaults.standard.synchronize() }
        }
    }
    
    private let themeNameKey = "themeName"
    public var themeName: String {
        get { return UserDefaults.standard.string(forKey: themeNameKey) ?? ""}
        set {
            UserDefaults.standard.set(newValue, forKey: themeNameKey)
            DispatchQueue.global().async { UserDefaults.standard.synchronize() }
        }
    }
    
    override public func wipeData() {
        super.wipeData()
        themeName = ThemeManager.defaultLightThemeName
    }
}

// MARK: FXKeychain extension

extension FXKeychain {
    
    // MARK: Helpers
    
    private func bool(forKey defaultName: String) -> Bool? {
        if let value = object(forKey: defaultName) as? Bool {
            return value
        }
        
        return nil;
    }
}
