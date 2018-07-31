//
//  FMZoomInAnimationController.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/11/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

public class FMZoomInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    public var getOriginFrame: (() -> CGRect)!
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.AnimationDuration.defaultDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? FMImageSlideViewController,
            let photoVC = toVC.pageViewController?.viewControllers?.first as? FMImagePreviewViewController
            else { return }
        
        let containerView = transitionContext.containerView
        
        let snapshot = photoVC.viewToSnapshot().snapshot()
        
        let bgView = UIView(frame: containerView.frame)
        containerView.addSubview(bgView)
        
        let originalSnapshotCornerRadius = snapshot.layer.cornerRadius
        let originalSnapshotSize = snapshot.frame.size
        
        let startFrame = self.getOriginFrame()
        
        snapshot.layer.cornerRadius = 0
        snapshot.frame = startFrame
        snapshot.contentMode = .scaleAspectFill
        snapshot.clipsToBounds = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        toVC.view.isHidden = true
        
        snapshot.alpha = 0
        bgView.backgroundColor = toVC.view.backgroundColor
        bgView.alpha = 0
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeCubic,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1) {
                                        snapshot.alpha = 1
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.9) {
                                        snapshot.frame = CGRect(origin: .zero, size: originalSnapshotSize)
                                        snapshot.center =  containerView.center
                                        snapshot.layer.cornerRadius = originalSnapshotCornerRadius
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.9) {
                                        bgView.alpha = 1
                                    }
        },
                                completion: { _ in
                                    toVC.view.isHidden = false
                                    snapshot.removeFromSuperview()
                                    bgView.removeFromSuperview()
                                    
                                    if transitionContext.isInteractive {
                                        if transitionContext.transitionWasCancelled {
                                            transitionContext.cancelInteractiveTransition()
                                        } else {
                                            transitionContext.finishInteractiveTransition()
                                        }
                                    }
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

