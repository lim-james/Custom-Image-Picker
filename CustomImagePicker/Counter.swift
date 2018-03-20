//
//  Counter.swift
//  CustomImagePicker
//
//  Created by James on 20/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class Counter {
    private var count: Int
    init() {
        self.count = 0
    }
    func current() -> Int {
        count += 1
        return count
    }
}
