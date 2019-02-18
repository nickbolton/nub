//
//  Math.swift
//  Bedrock
//
//  Created by Nick Bolton on 10/7/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

public func clamp<T : Comparable>(_ value: T, min minValue: T, max maxValue: T) -> T {
    return min(max(value, minValue), maxValue)
}
