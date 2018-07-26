//
//  CGImage+Help.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 5/23/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation
import ImageIO

open class RenderCGImage {
    public static let shared = RenderCGImage()
    
    public func createCGImage(atURL: URL) -> CGImage? {
        let options: CFDictionary = [kCGImageSourceShouldCache : kCFBooleanTrue,
                                     kCGImageSourceShouldAllowFloat: kCFBooleanTrue] as CFDictionary

        if let source = CGImageSourceCreateWithURL(atURL as CFURL, options) {
            return CGImageSourceCreateImageAtIndex(source, 0, nil)
        }
        
        return nil
    }
    
    public func createCGImage(atData: Data) -> CGImage? {
        if let source = CGImageSourceCreateWithData(atData as CFData, nil) {
            let options: CFDictionary = [kCGImageSourceCreateThumbnailWithTransform: kCFBooleanTrue,
                                         kCGImageSourceCreateThumbnailFromImageIfAbsent: kCFBooleanTrue] as CFDictionary
            return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
        }
        
        return nil
    }
    
    
}
