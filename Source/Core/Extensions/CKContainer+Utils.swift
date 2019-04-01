//
//  CKContainer+Utils.swift
//  Nub
//
//  Created by Nick Bolton on 3/27/19.
//

import UIKit
import CloudKit

extension CKContainer {
    
    func isICloudAvailable(_ onComplete: ((Bool)->Void)? = nil) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            onComplete?(accountStatus == .available)
        }
    }
}
