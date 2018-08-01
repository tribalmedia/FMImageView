//
//  Array.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 8/1/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
