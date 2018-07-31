//
//  FMZoomOutAnimationController.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/11/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

public class FMZoomOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    public var interactionInProgress = false
    
    public var getDestFrame: (() -> CGRect)!
    
    public var interactionController: FMPhotoInteractionAnimator?
    
    public init(interactionController: FMPhotoInteractionAnimator?) {
        self.interactionController = interactionController
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.AnimationDuration.defaultDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? FMImageSlideViewController,
            let toVC = transitionContext.viewController(forKey: .to),
            let photoVC = fromVC.pageViewController!.viewControllers?.first as? FMImagePreviewViewController
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        let pannedVector = fromVC.pageViewController!.view.frame.origin
        
        let snapshot = photoVC.viewToSnapshot().snapshot()
        
        let bgView = UIView(frame: containerView.frame)
        bgView.backgroundColor = .black
        bgView.alpha = 1
        
        containerView.addSubview(bgView)
        containerView.addSubview(snapshot)
        
        let originSnapshotSize = snapshot.frame.size
        
        snapshot.frame = CGRect(origin: .zero, size: originSnapshotSize)
        snapshot.clipsToBounds = true
        snapshot.contentMode = .scaleAspectFill
        snapshot.center = containerView.center
        
        snapshot.frame = CGRect(origin: CGPoint(x: snapshot.frame.origin.x + pannedVector.x,
                                                y: snapshot.frame.origin.y + pannedVector.y),
                                size: originSnapshotSize)
        
        fromVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            let destFrame: CGRect = self.getDestFrame()
            snapshot.frame = destFrame
            snapshot.layer.cornerRadius = 0
            bgView.alpha = 0
        }) { _ in
            fromVC.view.isHidden = false
            snapshot.removeFromSuperview()
            bgView.removeFromSuperview()
            
            if transitionContext.transitionWasCancelled {
                toVC.view.removeFromSuperview()
            }
            
            if transitionContext.isInteractive {
                if transitionContext.transitionWasCancelled {
                    transitionContext.cancelInteractiveTransition()
                } else {
                    transitionContext.finishInteractiveTransition()
                }
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
