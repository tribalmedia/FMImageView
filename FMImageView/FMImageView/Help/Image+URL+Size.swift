//
//  Image+URL+Size.swift
//  FMImageView
//  refer : https://gist.github.com/shpakovski/1744633
//  Created by Hoang Trong Anh on 5/23/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import ImageIO
import Foundation

open class ImageIOSizeImage: NSObject {
    public static let shared = ImageIOSizeImage()
    
    open func cgSizeOfImage(atURL: URL) -> CGSize {
        if let source = CGImageSourceCreateWithURL(atURL as CFURL, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, [kCGImageSourceShouldCache as String : 0] as CFDictionary),
            let width = (properties as? [AnyHashable: Any])?[kCGImagePropertyPixelWidth as String] as? NSNumber,
            let height = (properties as? [AnyHashable: Any])?[kCGImagePropertyPixelHeight as String] as? NSNumber {
                return CGSize(width: CGFloat(Float(truncating: width)), height: CGFloat(Float(truncating: height)))
            }
        
        return CGSize.zero
    }
    
    open func cgSizeOfImage(atImage: UIImage) -> CGSize {
        return atImage.size
    }
}
