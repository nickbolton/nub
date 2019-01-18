//
//  FileManager+Utils.swift
//  Nub
//
//  Created by Nick Bolton on 1/15/19.
//

import Foundation

extension FileManager {
    static public var documentsDirectory: String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    static public var cachesDirectory: String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}
