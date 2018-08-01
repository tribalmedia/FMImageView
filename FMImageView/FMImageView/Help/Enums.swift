//
//  Enums.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/29/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

public enum PanDirection: Int {
    case up, down, left, right
    public var isVertical: Bool { return [.up, .down].contains(self) }
    public var isHorizontal: Bool { return !isVertical }
}

public enum ContentMode: Int {
    case aspectFill
    case aspectFit
    case widthFill
    case heightFill
}

public enum Offset: Int {
    case begining
    case center
}

public enum SlideStatus {
    case pendding
    case completed
}

public enum ScrollDirection {
    case right
    case left
    case down
    case up
}
