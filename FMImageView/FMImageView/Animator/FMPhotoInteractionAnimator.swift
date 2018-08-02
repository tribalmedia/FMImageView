//
//  FMPhotoInteractionAnimator.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/11/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

public class FMPhotoInteractionAnimator: NSObject, UIViewControllerInteractiveTransitioning {
    
    // MARK: - Public
    
    public var interactionInProgress = false
    public var animator: UIViewControllerAnimatedTransitioning?

    // MARK: - Private
    
    private var destFrame: CGRect?
    private var transitionContext: UIViewControllerContextTransitioning?
    private var shouldCompleteTransition = false
    private weak var viewController: FMImageSlideViewController!
    fileprivate var originFrameForTransition: CGRect?
    lazy private var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        
        // So important to prevent unexpected behavior when mixing GestrureRecognizer and touchesBegan
        // especially when a touch event occur near edge of the screen where the system menu recognizer is also handing.
        pan.cancelsTouchesInView = false
        return pan
    }()
    
    // MARK: - Constructor
    
    init(viewController: FMImageSlideViewController, fromImageView: UIImageView) {
        super.init()
        
        self.viewController = viewController
        
        self.originFrameForTransition = fromImageView.convert(fromImageView.bounds, to: viewController.view)
        
        self.viewController.view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    // MARK: - Public functions
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
    }
    
    public func enable() {
        self.panGestureRecognizer.isEnabled = true
    }
    
    public func disable() {
        self.panGestureRecognizer.isEnabled = false
    }
    
    // MARK: - Private functions
    
    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
         self.viewController.runDelegate(gestureRecognizer)
        
        if gestureRecognizer.state == .began {
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
        } else {
            self.handlePanWithPanGestureRecognizer(gestureRecognizer,
                                                   viewToPan: self.viewController.pageViewController!.view,
                                                   anchorPoint:  CGPoint(x: self.viewController.view.bounds.midX,
                                                                         y: self.viewController.view.bounds.midY))
        }
    }
    
    private func handlePanWithPanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        let translatedPanGesturePoint = gestureRecognizer.translation(in: fromView)
        let newCenterPoint = CGPoint(x: anchorPoint.x, y: anchorPoint.y + translatedPanGesturePoint.y)
        
        viewToPan.center = newCenterPoint
        
        let verticalDelta = newCenterPoint.y - anchorPoint.y
        let backgroundAlpha = backgroundAlphaForPanningWithVerticalDelta(verticalDelta)
        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(backgroundAlpha)
        
        if gestureRecognizer.state == .ended {
            interactionInProgress = false
            finishPanWithPanGestureRecognizer(gestureRecognizer, verticalDelta: verticalDelta,viewToPan: viewToPan, anchorPoint: anchorPoint)
        }
    }
    
    private func finishPanWithPanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, verticalDelta: CGFloat, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        let returnToCenterVelocityAnimationRatio = 0.00007
        let panDismissDistanceRatio = 50.0 / 667.0 // distance over iPhone 6 height
        let panDismissMaximumDuration = 0.45
        
        let velocityY = gestureRecognizer.velocity(in: gestureRecognizer.view).y
        
        var animationDuration = (Double(abs(velocityY)) * returnToCenterVelocityAnimationRatio) + 0.2
        var animationCurve: UIViewAnimationOptions = .curveEaseOut
        var finalPageViewCenterPoint = anchorPoint
        var finalBackgroundAlpha = 1.0
        
        let dismissDistance = panDismissDistanceRatio * Double(fromView.bounds.height)
        let isDismissing = Double(abs(verticalDelta)) > dismissDistance
        
        var didAnimateUsingAnimator = false
        
        if isDismissing {
            if let animator = self.animator, let transitionContext = transitionContext {
                animator.animateTransition(using: transitionContext)
                didAnimateUsingAnimator = true
            } else {
                let isPositiveDelta = verticalDelta >= 0
                let modifier: CGFloat = isPositiveDelta ? 1 : -1
                let finalCenterY = fromView.bounds.midY + modifier * fromView.bounds.height
                finalPageViewCenterPoint = CGPoint(x: fromView.center.x, y: finalCenterY)
                
                animationDuration = Double(abs(finalPageViewCenterPoint.y - viewToPan.center.y) / abs(velocityY))
                animationDuration = min(animationDuration, panDismissMaximumDuration)
                animationCurve = .curveEaseOut
                finalBackgroundAlpha = 0.0
            }
        }
        
        if didAnimateUsingAnimator {
            self.transitionContext = nil
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: { () -> Void in
                viewToPan.center = finalPageViewCenterPoint
                fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(CGFloat(finalBackgroundAlpha))
            }, completion: { finished in
                if isDismissing {
                    self.transitionContext?.finishInteractiveTransition()
                } else {
                    self.transitionContext?.cancelInteractiveTransition()
                }
                
                self.transitionContext?.completeTransition(isDismissing && !(self.transitionContext?.transitionWasCancelled ?? false))
                self.transitionContext = nil
            })
        }
    }
    
    private func backgroundAlphaForPanningWithVerticalDelta(_ delta: CGFloat) -> CGFloat {
        return 1 - min(abs(delta) / 400, 1.0)
    }
}

// MARK: - FMPhotoInteractionAnimator extension

extension FMPhotoInteractionAnimator:  UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = FMZoomInAnimationController()
        animationController.getOriginFrame = self.getOriginFrameForTransition
        return animationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let photoPresenterViewController = dismissed as? FMImageSlideViewController else { return nil }
        let animationController = FMZoomOutAnimationController(interactionController: photoPresenterViewController.swipeInteractionController)
        animationController.getDestFrame = self.getOriginFrameForTransition
        return animationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? FMZoomOutAnimationController,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        
        interactionController.animator = animator
        return interactionController
    }
    
    private func getOriginFrameForTransition() -> CGRect {
        if let destFrame = self.viewController.getNewDestinatonFrame() {
            return destFrame
        }
        return self.originFrameForTransition ?? CGRect.zero
    }
}
