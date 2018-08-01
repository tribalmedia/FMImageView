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
    
    /**
     Returns an color hex (String)
     */
    func extractColor() -> String? {
        guard let cgimage = self.cgImage else {
            return nil
        }
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(cgimage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        var color: UIColor?
        
        if pixel[3] > 0 {
            let alpha:CGFloat = CGFloat(pixel[3]) / 255.0
            let multiplier:CGFloat = alpha / 255.0
            
            color = UIColor(red: CGFloat(pixel[0]) * multiplier, green: CGFloat(pixel[1]) * multiplier, blue: CGFloat(pixel[2]) * multiplier, alpha: alpha)
        }else{
            
            color = UIColor(red: CGFloat(pixel[0]) / 255.0, green: CGFloat(pixel[1]) / 255.0, blue: CGFloat(pixel[2]) / 255.0, alpha: CGFloat(pixel[3]) / 255.0)
        }
        
        #if swift(>=4.1)
        pixel.deinitialize(count: 4)
        pixel.deallocate()
        #else
        pixel.deinitialize()
        pixel.deallocate(capacity: 4)
        #endif
        
        if let color = color {
            return color.toHexString()
        }
        return nil
    }
    
    /**
     Convert color to hex
     - parameter color: UIColor
     */
    func toHexString(color: UIColor) -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
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
                if let img = _image, let hex = img.extractColor() {
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
