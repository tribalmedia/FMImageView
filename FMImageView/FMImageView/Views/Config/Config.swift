//
//  Config.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/26/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

public struct Config {
    public var initImageView: UIImageView
    public var initIndex: Int
    
    public var isBackgroundColorByExtraColorImage: Bool = false
    
    public var bottomView: HorizontalStackView?
    
    public init(initImageView: UIImageView, initIndex: Int) {
        self.initImageView = initImageView
        self.initIndex = initIndex
    }
}
