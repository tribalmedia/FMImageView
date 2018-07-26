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

extension ImagePreviewViewController: Move {
    func moving(_ sender: UIPanGestureRecognizer) {
        self.scrollView.moveScrollViewFrame(sender)
    }
}

class ImagePreviewViewController: UIViewController {
    var itemIndex: Int = -1
    var image: UIImage!
    var imageURL: URL!
    var scrollView: ImageZoomView!
    
    var slideStatus: SlideStatus? {
        didSet {
            self.scrollView.slideStatus = self.slideStatus
        }
    }
    
    
    weak var _delegate: ImageSlideFMDelegate?
    
    var parentVC: ImageSlideViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollView = ImageZoomView(config: ConfigureZoomView(imageContentMode: .aspectFit, initialOffset: .center, maxScaleFromMinScale: Constants.Scale.cMax))
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = UIColor.clear
        scrollView._delegate = self
        
        FMAlert.shared.__delegate = self

        self.view = scrollView
        
        if let fromImage = self.image {
            DispatchQueue.main.async {
                self.scrollView.displayImage(fromImage)
            }
        } else {
            let image = UIImage(withBackground: UIColor.black)
            scrollView.displayImage(image)
            self.updateImage()
        }
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
    
    private func updateImage() {
        DispatchQueue.main.async {
            FMLoadingView.shared.show()
        }
        ImageLoader.sharedLoader.imageForUrl(url: imageURL) { (image, urlString, error) in
            if let _ = error {
                DispatchQueue.main.async {
                    FMAlert.shared.show(message: "Whoops! Something went wrong.\nPlease try again!")
                }
                
            }
            
            if let image = image {
                self.scrollView.displayImage(image)
            }
            DispatchQueue.main.async {
                FMLoadingView.shared.hide()
            }
        }
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

extension ImagePreviewViewController: RefreshProtocol {
    func refreshHandling() {
        DispatchQueue.main.async {
            FMAlert.shared.hide()
        }
        updateImage()
    }
}


extension ImagePreviewViewController: ImagePreviewFMDelegate {
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
