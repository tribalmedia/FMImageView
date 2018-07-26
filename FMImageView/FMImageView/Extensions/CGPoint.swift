//
//  CGPoint.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/26/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
}
