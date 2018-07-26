//
//  FMImageDataSource.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/24/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

public class FMImageDataSource {
    var useURLs: Bool = false
    
    var images: [UIImage]?
    
    var imageURLs: [URL]?
    
    public init(useURLs: Bool) {
        self.useURLs = useURLs
    }
    
    convenience public init(imageURLs: [URL]) {
        self.init(useURLs: true)
        
        self.imageURLs = imageURLs
    }
    
    convenience public init(images: [UIImage]) {
        self.init(useURLs: false)
        
        self.images = images
    }
    
    func selectImage(index: Int) -> UIImage? {
        
        guard let images = self.images else {
            return nil
        }
        
        return images[index]
    }
    
    func selectImageURL(index: Int) -> URL? {
        guard let imageURLs = self.imageURLs else {
            return nil
        }
        
        return imageURLs[index]
    }
    
    func total() -> Int {
        return self.useURLs ? self.imageURLs?.count ?? 0 : self.images?.count ?? 0
    }
}
