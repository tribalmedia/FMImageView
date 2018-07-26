//
//  ImageLoader.swift
//  FMImageView
//  refer : https://github.com/MengTo/Spring/blob/master/Spring/ImageLoader.swift
//
//  Created by Hoang Trong Anh on 7/2/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//
import UIKit
import Foundation


public class ImageLoader {
    
    var cache = NSCache<NSString, NSData>()
    
    public class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    public func imageForUrl(url: URL, completionHandler: @escaping(_ image: UIImage?, _ url: String, _ error: NetworkingErrors?) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            var data: NSData?
            
            if let dataCache = self.cache.object(forKey: url.absoluteString as NSString) {
                data = (dataCache) as NSData
                
            } else {
                guard let data = NSData(contentsOf: url) else {
                    completionHandler(nil, url.absoluteString, .dataReturnedNil)
                    return
                }
                
                self.cache.setObject(data, forKey: url.absoluteString as NSString)
            }
            
            if let goodData = data {
                let image = UIImage(data: goodData as Data)
                
                DispatchQueue.main.async(execute: {() in
                    completionHandler(image, url.absoluteString, nil)
                })
                return
            }
            
            let downloadTask: URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                
                // Check for errors in responses.
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain == NSURLErrorDomain && (nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorTimedOut) {
                        completionHandler(nil, url.absoluteString, .noInternetConnection)
                    } else {
                        completionHandler(nil, url.absoluteString, .returnedError(error))
                    }
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode <= 200 && response.statusCode >= 299 {
                    completionHandler(nil, url.absoluteString, .invalidStatusCode("Request returned status code other than 2xx \(response)"))
                    return
                }
                
                if let _data = data {
                    let image = UIImage(data: _data)
                    
                    self.cache.setObject(_data as NSData, forKey: url.absoluteString as NSString)
                    
                    DispatchQueue.main.async(execute: {() in
                        completionHandler(image, url.absoluteString, nil)
                    })
                    return
                } else {
                    completionHandler(nil, url.absoluteString, .dataReturnedNil)
                }
            })
            downloadTask.resume()
            
        }
        
    }
}

public enum NetworkingErrors: Error {
    case errorParsingJSON
    case noInternetConnection
    case dataReturnedNil
    case returnedError(Error)
    case invalidStatusCode(String)
    case customError(String)
}
