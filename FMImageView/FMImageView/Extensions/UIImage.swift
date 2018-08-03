//
//  UIImage.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/27/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

extension UIImage {
    
    /**
     Returns an UIImage with a specified background color.
     - parameter color: The color of the background
     */
    convenience init(withBackground color: UIColor) {
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        context.setFillColor(color.cgColor);
        context.fill(rect)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.init(ciImage: CIImage(image: image)!)
        
    }
    
    var averageColor: String? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [kCIContextWorkingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: nil)
        
        if let colorHex = UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255).hexString() {
            return colorHex
        }
        
        return nil
    }
    
    func fm_setImage(url: URL?, completed: @escaping (_ image: UIImage?,_ error: NetworkingErrors?, _ extraColorHex: String?) -> ()) {
        guard let url = url else {
            completed(nil, .customError("URL not found !"), nil)
            return
        }
        
        
        let downloadDispatchGroup = DispatchGroup()
        
        downloadDispatchGroup.enter()

        var _image: UIImage?
        var _error: NetworkingErrors?
        
        ImageLoader.sharedLoader.imageForUrl(url: url) { (image, urlString, error) in
            if let _ = error {
                // mark code
                _error = error
                
                downloadDispatchGroup.leave()
            }
            
            _image = image
            
            downloadDispatchGroup.leave()
        }
        
        downloadDispatchGroup.notify(queue: DispatchQueue.main) {
            guard let error = _error else {
                if let img = _image, let hex = img.averageColor {
                    completed(_image, nil, hex)
                    
                    return
                }
                
                completed(_image, nil, nil)
                
                return
            }
            
            completed(_image, error, nil)
        }
    }
    
}
