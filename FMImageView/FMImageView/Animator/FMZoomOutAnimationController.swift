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
//        print("fromVC: \(fromVC)")
//        print("photoVC: \(photoVC.view.backgroundColor)")
        
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
        
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.9) {
                    // snapshot.frame = self.realDestinationFrame(scaledFrame: self.getDestFrame(), realSize: snapshot.frame.size)
                    snapshot.frame = self.getDestFrame()
                    snapshot.layer.cornerRadius = 0
                    bgView.alpha = 0
//                    bgView.backgroundColor = bgView.backgroundColor?.withAlphaComponent(0)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                    snapshot.alpha = 0.0
                }
        },
            completion: { _ in
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
        })
    }
    
    private func realDestinationFrame(scaledFrame: CGRect, realSize: CGSize) -> CGRect {
        let scaledSize = scaledFrame.size
        let ratio = realSize.width / realSize.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var width: CGFloat = scaledSize.width
        var height: CGFloat = scaledSize.height
        
        if ratio >= 1 {
            let scaleRatio = scaledSize.height / realSize.height
            width = realSize.width * scaleRatio
            x = -(width - scaledSize.width) / 2
        } else {
            let scaleRatio = scaledSize.width / realSize.width
            height = realSize.height * scaleRatio
            y = -(height - scaledSize.height) / 2
        }
        
        let frame = CGRect(x: scaledFrame.origin.x + x,
                           y: scaledFrame.origin.y + y,
                           width: width,
                           height: height)
        return frame
    }
}
