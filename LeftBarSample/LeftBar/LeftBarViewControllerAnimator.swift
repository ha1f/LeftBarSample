//
//  LeftBarViewControllerAnimator.swift
//  LeftBarSample
//
//  Created by はるふ on 2019/05/08.
//  Copyright © 2019 はるふ. All rights reserved.
//

import UIKit



// Q: What's the benefit of snapShotView?

/// - seealso: [Customizing the Transition Animations](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html)
final class LeftBarAnimationController: NSObject, UIViewControllerTransitioningDelegate {
    struct Config {
        var shouldMoveBaseViewController: Bool
        var duration: TimeInterval
        var contentViewShadowOpacity: Float = 0.5
        
        init(shouldMoveBaseViewController: Bool, duration: TimeInterval = 0.3) {
            self.shouldMoveBaseViewController = shouldMoveBaseViewController
            self.duration = duration
        }
    }
    
    let interactiveDismissAnimator = UIPercentDrivenInteractiveTransition()
    let config = Config(shouldMoveBaseViewController: false)
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LeftBarDismissAnimator(config: config)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LeftBarPresentAnimator(config: config)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // Present animation is not interactive
        return nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveDismissAnimator
    }
    
}

private final class LeftBarDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let _config: LeftBarAnimationController.Config
    
    init(config: LeftBarAnimationController.Config) {
        _config = config
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return _config.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? LeftBarViewController,
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                transitionContext.completeTransition(true)
                return
        }
        
        let initialFrame = transitionContext.initialFrame(for: fromViewController)
        let translationX = initialFrame.width * fromViewController.coverRatio
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [_config] in
            fromViewController.view.transform = CGAffineTransform(translationX: -translationX, y: 0)
            toViewController.view.alpha = 1.0
            fromViewController.contentView.layer.shadowOpacity = 0.0
            if _config.shouldMoveBaseViewController {
                toViewController.view.transform = .identity
            }
        }, completion: { [_config] completed in
            let success = !transitionContext.transitionWasCancelled
            if success {
                fromViewController.view.removeFromSuperview()
            } else {
                // Only this is not recovered automatically.
                fromViewController.contentView.layer.shadowOpacity = _config.contentViewShadowOpacity
            }
            transitionContext.completeTransition(success)
        })
    }
}

private final class LeftBarPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let _config: LeftBarAnimationController.Config
    
    init(config: LeftBarAnimationController.Config) {
        _config = config
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return _config.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) as? LeftBarViewController
            else {
                transitionContext.completeTransition(true)
                return
        }
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = finalFrame
        transitionContext.containerView.addSubview(toViewController.view)
        
        let translationX = finalFrame.width * toViewController.coverRatio
        toViewController.view.transform = CGAffineTransform(translationX: -translationX, y: 0)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [_config] in
            toViewController.view.transform = .identity
            fromViewController.view.alpha = 0.3
            toViewController.contentView.layer.shadowOpacity = _config.contentViewShadowOpacity
            if _config.shouldMoveBaseViewController {
                fromViewController.view.transform = CGAffineTransform(translationX: translationX, y: 0)
            }
        }, completion: { completed in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toViewController.view.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        })
    }
}
