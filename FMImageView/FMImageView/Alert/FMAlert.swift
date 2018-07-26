//
//  FMAlert.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/2/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation
import UIKit

protocol RefreshProtocol: class {
    func refreshHandling()
}

class FMAlert {
    private let transparentView: UIView
    private let refreshButton: UIButton
    private let messageLabel: UILabel
  
    static let shared = FMAlert()
    
    weak var __delegate: RefreshProtocol?
    
    private init() {
        let heightTranparentView = UIScreen.main.bounds.width - Constants.Layout.cHeightTV - Constants.Layout.cHeightBV
        
        self.transparentView = UIView(frame: CGRect(x: 0, y: Constants.Layout.cHeightTV, width: UIScreen.main.bounds.width, height: heightTranparentView))
        
        self.transparentView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        self.refreshButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        self.refreshButton.center = self.transparentView.center
        self.refreshButton.setImage(UIImage(named: "icn_refresh", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        
        
        self.messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        self.messageLabel.center = CGPoint(x: self.transparentView.center.x, y: self.transparentView.center.y + 35.0)
        self.messageLabel.textAlignment = .center
        self.messageLabel.textColor = .white
        self.messageLabel.numberOfLines = 2
        self.messageLabel.adjustsFontSizeToFitWidth = true
        
        
        self.transparentView.addSubview(self.refreshButton)
        self.transparentView.addSubview(self.messageLabel)
        
        
        
        self.refreshButton.addTarget(self, action: #selector(refresh(_:)), for: .touchUpInside)
    }
    
    @objc func refresh(_ sender: UIButton) {
        __delegate?.refreshHandling()
    }
    
    func show(message: String?) {
        self.messageLabel.text = message
        
        self.transparentView.removeFromSuperview()
        UIApplication.shared.keyWindow?.addSubview(self.transparentView)
        self.transparentView.alpha = 0
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
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
