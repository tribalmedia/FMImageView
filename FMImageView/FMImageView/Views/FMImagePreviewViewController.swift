//
//  ImagePreviewViewController.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/27/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

protocol Move: class {
    func moving(_ sender: UIPanGestureRecognizer)
}

extension FMImagePreviewViewController: Move {
    func moving(_ sender: UIPanGestureRecognizer) {
        self.scrollView.moveScrollViewFrame(sender)
    }
}

class FMImagePreviewViewController: UIViewController {
    var itemIndex: Int = -1
    
    var image: UIImage? = UIImage(withBackground: UIColor.clear)
    
    var imageURL: URL?
    
    var scrollView: ImageZoomView!
    
    var slideStatus: SlideStatus? {
        didSet {
            self.scrollView.slideStatus = self.slideStatus
        }
    }
    
    
    weak var _delegate: ImageSlideFMDelegate?
    
    var parentVC: FMImageSlideViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollView = ImageZoomView(config: ConfigureZoomView(imageContentMode: .aspectFit, initialOffset: .center, maxScaleFromMinScale: Constants.Scale.cMax))
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = UIColor.clear
        scrollView._delegate = self

        self.view = scrollView
        
        if let fromImage = self.image {
            DispatchQueue.main.async {
                self.scrollView.displayImage(fromImage)
            }
            
            if let extraColor = fromImage.averageColor {
                guard let _ = self.parentVC?.view.backgroundColor else {
                    if self.parentVC!.tupleColorBacground.count < self.parentVC!.datasource.total() {
                        self.parentVC?.tupleColorBacground.append((pageIndex: self.itemIndex, hexColor: extraColor))
                    }

                    self.parentVC?.view.backgroundColor = UIColor(hexString: extraColor, alpha: 1.0)
                    
                    return
                }
            }
        } else {
            self.scrollView.displayImage(self.image!)
        }
    }
    
    func update(image: UIImage?) {
        guard let image = image else {return}
        
        self.scrollView.displayImage(image)
    }
    
    public func viewToSnapshot() -> UIView {
        guard let scrollView = scrollView, let imgV = scrollView._imageView else {
            return self.view
        }
        
        return imgV
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parentVC?.mDelegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            FMAlert.shared.hide()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension FMImagePreviewViewController: ImagePreviewFMDelegate {
    func notificationHandlingModal(type: TypeName.Modal) {
        self._delegate?.handlingModal(type: type)
    }
    
    func notificationHandlingSwipe(type: TypeName.Swipe) {
        self._delegate?.handlingSwipe(type: type)
    }
    
    func notificationHandlingElasticityOfTopViewAndBottomView(type: TypeName.Elasticity) {
        self._delegate?.handlingElasticityOfTopViewAndBottomView(type: type)
    }
}
