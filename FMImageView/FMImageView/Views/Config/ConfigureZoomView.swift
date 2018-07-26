//
//  ConfigureZoomView.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/26/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

public struct ConfigureZoomView {
    public var _imageContentMode: ContentMode
    public var _initialOffset: Offset
    public var _maxScaleFromMinScale: CGFloat
    
    public init(imageContentMode: ContentMode?, initialOffset: Offset?, maxScaleFromMinScale: CGFloat?) {
        self._imageContentMode = imageContentMode ?? .aspectFit
        self._initialOffset = initialOffset ?? .center
        self._maxScaleFromMinScale = maxScaleFromMinScale ?? Constants.Scale.cMax
    }
}
