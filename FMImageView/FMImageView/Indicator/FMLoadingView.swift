//
//  Indicator.swift
//  FMImageView
//  refer : https://github.com/tribalmedia/FMPhotoPicker/blob/master/FMPhotoPicker/FMPhotoPicker/source/Utilities/FMLoadingView.swift
//  Created by Hoang Trong Anh on 7/2/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation
import UIKit

class FMLoadingView {
    private let transparentView: UIView
    private let indicator: UIActivityIndicatorView
    
    static let shared = FMLoadingView()
    
    private init() {
        let rootVC = (UIApplication.shared.delegate?.window??.rootViewController)!
        
        self.transparentView = UIView(frame: rootVC.view.frame)
        self.transparentView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        self.indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        self.indicator.center = self.transparentView.center
        self.indicator.color = .white
        
        self.transparentView.addSubview(self.indicator)
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self.transparentView)
        self.transparentView.alpha = 0
        self.indicator.startAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.transparentView.alpha = 1
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        DispatchQueue.global(qos: .default).async(execute: {
                            DispatchQueue.main.sync(execute: {
                                self.transparentView.alpha = 0
                            })
                        })
        },
                       completion: { completed in
                        self.transparentView.removeFromSuperview()
                        self.indicator.stopAnimating()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
