//
//  DataProvider.swift
//  Nub
//
//  Created by Nick Bolton on 11/4/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

import UIKit
import Siesta
import Reachability

extension Notification.Name {
    public static let UnauthorizedAccess = Notification.Name(rawValue: "com.pixelbleed.unauthorizedAccess")
    public static let ReauthorizedAccess = Notification.Name(rawValue: "com.pixelbleed.reauthorizedAccess")
}

struct DataResult {
    let data: [Any]
    func typedObject<T>() -> T? {
        return data.first as? T
    }
    func typedArray<T>() -> [T] {
        return data as? [T] ?? []
    }
}

protocol DataObserver: class {
    func dataChanged(_ data: DataResult)
    func resourceChanged(_ resource: Resource, event: ResourceEvent)
}

extension DataObserver {
    func dataChanged(_ data: DataResult) {}
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {}
}

protocol DataProvider {
    var observer: DataObserver? { get set }
    var repositoriesResource: Resource? { get set }
    func load(forced: Bool)
    func invalidate()
}

class SiestaDataProvider<T>: NSObject, DataProvider, ResourceObserver {
    
    weak var observer: DataObserver?
    private (set) var reachability = Reachability()

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground(noti:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(noti:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reauthorizedAccess(noti:)),
                                               name: NSNotification.Name.ReauthorizedAccess,
                                               object: nil)
        startReachability()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var repositoriesResource: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            repositoriesResource?.addObserver(self)
            load()
        }
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        switch event {
        case .newData(_), .notModified:
            observer?.dataChanged(DataResult(data: resource.typedContent() ?? []))
        default:
            break
        }
        observer?.resourceChanged(resource, event: event)
    }
    
    func load(forced: Bool = false) {
        if forced {
            repositoriesResource?.invalidate()
        }
        repositoriesResource?.loadIfNeeded()
    }
    
    func invalidate() {
        repositoriesResource?.invalidate()
    }
    
    @objc open func reauthorizedAccess(noti: NSNotification) {
        DispatchQueue.main.async { [weak self] in self?.load(forced: true) }
    }
    
    @objc open func applicationWillEnterForeground(noti: NSNotification) {
        startReachability()
        load()
    }
    
    @objc open func applicationDidEnterBackground(noti: NSNotification) {
        stopReachability()
        repositoriesResource?.invalidate()
    }
    
    private func startReachability() {
        do {
            try reachability?.startNotifier()
            reachability?.whenReachable = { [weak self] reachability in
                self?.load()
            }
            reachability?.whenUnreachable = { [weak self] reachability in
                self?.invalidate()
            }
        } catch {
            Logger.shared.error("\(error)")
        }
    }
    
    private func stopReachability() {
        reachability?.stopNotifier()
        reachability?.whenReachable = nil
        reachability?.whenUnreachable = nil
    }
}

class SiestaDataProviderViewControllerAdapter<T>: NSObject, DataObserver, DataProvider {
    
    weak var viewController: UIViewController?
    private (set) var dataProvider: DataProvider?
    internal weak var observer: DataObserver?

    var repositoriesResource: Resource? {
        get { return dataProvider?.repositoriesResource }
        set { dataProvider?.repositoriesResource = newValue }
    }

    init(viewController: UIViewController) {
        super.init()
        self.dataProvider = SiestaDataProvider<T>()
        self.viewController = viewController
        dataProvider?.observer = self
    }
    
    func dataChanged(_ result: DataResult) {
        observer?.dataChanged(result)
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        switch event {
        case .error:
            if resource.latestError?.httpStatusCode != 401 {
                // retry
            }
        default:
            break
        }
        observer?.resourceChanged(resource, event: event)
    }
    
    func load(forced: Bool) {
        dataProvider?.load(forced: forced)
    }
    
    func invalidate() {
        dataProvider?.invalidate()
    }
}
