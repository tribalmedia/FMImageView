//
//  ImageZoomView.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/27/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit
import AVFoundation

class ImageZoomView: UIScrollView {

    var _imageView: UIImageView?
    
    fileprivate var _imageSize: CGSize = CGSize.zero
    
    fileprivate var _pointToCenterAfterResize: CGPoint!
    
    fileprivate var _scaleToRestoreAfterResize: CGFloat!
    
    private var initialTouchPoint: CGPoint = CGPoint.zero
    
    private var _pinchGestureRecognizer: UIPinchGestureRecognizer?
    
    private var _isPinching: Bool = false
    
    var config: ConfigureZoomView = ConfigureZoomView(imageContentMode: nil,
                                                      initialOffset: nil,
                                                      maxScaleFromMinScale: nil)
    
    var slideStatus: SlideStatus? = .completed
    
    weak var _delegate: ImagePreviewFMDelegate?
    
    public init(config: ConfigureZoomView) {
        self.config = config
        super.init(frame: CGRect.zero)
        self.customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    private func customInit() {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
    }
    
    func moveScrollViewFrame(_ sender: UIPanGestureRecognizer) {
        guard let window = window else {return}
        
        let touchPoint = sender.location(in: window)
        
        switch sender.state {
        case .began:
            
            initialTouchPoint = touchPoint
        case .changed:
            
            frame.origin.y = touchPoint.y - initialTouchPoint.y
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: Constants.AnimationDuration.defaultDuration, animations: {
                self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            })
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = self._imageView else {
            return
        }
        
        // center the zoom view as it becomes smaller than the size of the screen
        let boundsSize: CGSize = self.bounds.size
        var frameToCenter: CGRect = imageView.frame
        
        // center horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        self._imageView!.frame = frameToCenter
    }

    override var frame: CGRect {
        willSet{
            // check to see if there is a resize coming. prepare if there is one
            let sizeChanging: Bool = !frame.size.equalTo(newValue.size)
            if sizeChanging { self.prepareToResize()}
        }
        didSet {
            // check to see if there was a resize. recover if there was one
            let sizeChanged: Bool = !frame.size.equalTo(oldValue.size)
            if sizeChanged { self.recoverFromResizing() }
        }
    }

    
    
    // ***********************************************
    // MARK: Configure scrollview to display image
    // ***********************************************
    
    func displayImage(_ image: UIImage) {
        
        if let _ = self._imageView {
            self._imageView?.removeFromSuperview()
            self._imageView = nil
        }
        
        self.zoomScale = Constants.Scale.cMin
        
        self._imageView = UIImageView(image: image)
        
        _pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureTarget(_:)))
        self.addGestureRecognizer(_pinchGestureRecognizer!)
        
        self.addSubview(self._imageView!)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageZoomView.doubleTapGestureRecognizer(_:)))
        tapGesture.numberOfTapsRequired = 2
        _imageView!.isUserInteractionEnabled = true
        _imageView!.addGestureRecognizer(tapGesture)
        
        self.configureForImageSize(image.size)
    }
    
    @objc func pinchGestureTarget(_ sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            if _isPinching == false {
                _isPinching = true
                self._delegate?.notificationHandlingElasticityOfTopViewAndBottomView(type: .elasticity_out)
            }
        } else if sender.state == UIGestureRecognizerState.changed {
            
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if zoomScale > minimumZoomScale {
                self._delegate?.notificationHandlingSwipe(type: .disable)
            } else {
                self._delegate?.notificationHandlingSwipe(type: .enable)
                self._delegate?.notificationHandlingElasticityOfTopViewAndBottomView(type: .elasticity_in)
                _isPinching = false
            }
        }
    }
    
    
    private func configureForImageSize(_ imageSize: CGSize) {
        
        _imageSize = imageSize
        self.contentSize = imageSize
        self.setMaxMinZoomScalesForCurrentBounds()
        self.zoomScale = self.minimumZoomScale
        
        switch self.config._initialOffset {
        case .begining:
            contentOffset =  CGPoint.zero
        case .center:
            let xOffset = contentSize.width < bounds.width ? 0 : (contentSize.width - bounds.width) / 2
            let yOffset = contentSize.height < bounds.height ? 0 : (contentSize.height - bounds.height) / 2
            
            switch self.config._imageContentMode {
            case .aspectFit:
                contentOffset =  CGPoint.zero
            case .aspectFill:
                contentOffset = CGPoint(x: xOffset, y: yOffset)
            case .heightFill:
                contentOffset = CGPoint(x: xOffset, y: 0)
            case .widthFill:
                contentOffset = CGPoint(x: 0, y: yOffset)
            }
        }
    }
    
    fileprivate func setMaxMinZoomScalesForCurrentBounds() {
        // calculate min/max zoomscale
        let xScale = bounds.width / _imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = bounds.height / _imageSize.height   // the scale needed to perfectly fit the image height-wise
        
        var minScale: CGFloat = 1
        
        switch self.config._imageContentMode {
        case .aspectFill:
            minScale = max(xScale, yScale)
        case .aspectFit:
            minScale = min(xScale, yScale)
        case .widthFill:
            minScale = xScale
        case .heightFill:
            minScale = yScale
        }
        
        let maxScale = self.config._maxScaleFromMinScale * minScale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale * 0.999 // the multiply factor to prevent user cannot scroll page while they use this control in UIPageViewController
    }
    
    
    
    // ***********************************************
    // MARK: Configure scrollview to display image
    // ***********************************************
    
    
    private func prepareToResize() {
        
        let boundsCenter: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        _pointToCenterAfterResize = self.convert(boundsCenter, to: self._imageView)
        
        _scaleToRestoreAfterResize = self.zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        
        if Float(_scaleToRestoreAfterResize) <= Float(self.minimumZoomScale) + .ulpOfOne {
            _scaleToRestoreAfterResize = 0
        }
        
    }
    
    private func recoverFromResizing() {
        
        self.setMaxMinZoomScalesForCurrentBounds()
        
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        let maxZoomScale: CGFloat = max(self.minimumZoomScale, _scaleToRestoreAfterResize)
        self.zoomScale = min(self.maximumZoomScale, maxZoomScale)
        
        // Step 2: restore center point, first making sure it is within the allowable range.
        
        // 2a: convert our desired center point back to our own coordinate space
        let boundsCenter: CGPoint = self.convert(_pointToCenterAfterResize, from: self._imageView)
        
        // 2b: calculate the content offset that would yield that center point
        var offset: CGPoint = CGPoint(x: boundsCenter.x - self.bounds.size.width / 2.0, y: boundsCenter.y - self.bounds.size.height / 2.0)
        
        // 2c: restore offset, adjusted to be within the allowable range
        let maxOffset: CGPoint = self.maximumContentOffset()
        let minOffset: CGPoint = self.minimumContentOffset()
        
        var realMaxOffset: CGFloat = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffset)
        
        realMaxOffset = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffset)
        
        self.contentOffset = offset
        
    }
    
    private func maximumContentOffset() -> CGPoint {
        let contentSize: CGSize = self.contentSize
        let boundsSize: CGSize = self.bounds.size
        return CGPoint(x: contentSize.width - boundsSize.width, y: contentSize.height - boundsSize.height)
    }
    
    private func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
    
    @objc func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // zoom out if it bigger than middle scale point. Else, zoom in
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
            
            self._delegate?.notificationHandlingElasticityOfTopViewAndBottomView(type: .elasticity_in)
            self._delegate?.notificationHandlingSwipe(type: .enable)
        }
        else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(self.config._maxScaleFromMinScale, center: center)
            zoom(to: zoomRect, animated: true)

            self._delegate?.notificationHandlingElasticityOfTopViewAndBottomView(type: .elasticity_out)
            self._delegate?.notificationHandlingSwipe(type: .disable)
        }
    }
    
    fileprivate func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        // the zoom rect is in the content view's coordinates.
        // at a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        // as the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width  = frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    /// Adjust the position of the image after zooming
    func updateImageCenter() {
        guard let imageView = _imageView, let image = imageView.image else { return }
        
        // Find the image size of UIImageView at UIViewContentMode.ScaleAspectFit
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        
        var imageSize = CGSize(width: frame.size.width, height: frame.size.height)
        imageSize.width *= zoomScale
        imageSize.height *= zoomScale
        
        var point: CGPoint = CGPoint.zero
        point.x = imageSize.width / 2
        if imageSize.width < bounds.width {
            point.x += (bounds.width - imageSize.width) / 2
        }
        point.y = imageSize.height / 2
        if imageSize.height < bounds.height {
            point.y += (bounds.height - imageSize.height) / 2
        }
        _imageView?.center = point
    }
    
}

// ***********************************************
// MARK: UIScrollViewDelegate
// ***********************************************

extension ImageZoomView: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageCenter()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self._imageView
    }
    
    // MARK: - Scroll delegate
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.isEnabled = false;
        }
    }
}

// ***********************************************
// MARK: UIGestureRecognizerDelegate
// ***********************************************

extension ImageZoomView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
