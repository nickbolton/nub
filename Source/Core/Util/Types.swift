//
//  Types.swift
//  Nub
//
//  Created by Nick Bolton on 7/10/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import Foundation

public typealias DefaultHandler = (() -> Void)
public typealias DefaultFailureHandler = ((Error?) -> Void)
public typealias BooleanResultHandler = ((Bool) -> Void)
