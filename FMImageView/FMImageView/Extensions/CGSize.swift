//
//  CGSize.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/26/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

extension CGSize {
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}
