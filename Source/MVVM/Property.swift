//
//  Property.swift
//  Nub iOS
//
//  Created by Nick Bolton on 11/14/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

import UIKit

protocol Observer {
    func valueChanged()
}

struct ObservableProperty<Element: Equatable> {
    var value: Element {
        didSet {
            if value != oldValue {
                observer.valueChanged()
            }
        }
    }
    private let observer: Observer
    init(value: Element, observer: Observer) {
        self.value = value
        self.observer = observer
    }
}
