//
//  ImageView.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/22/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

extension UIImageView {
    func load(url: URL, callback: @escaping (UIImage) -> ()) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        callback(image)
                    }
                }
            }
        }
    }
}

extension URL {
    func load(callback: @escaping (UIImage) -> ()) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: self) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        callback(image)
                    }
                }
            }
        }
    }
}

