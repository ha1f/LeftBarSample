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
        
        init(shouldMoveBaseViewController: Bool, duration: TimeInterval = 0.3) {
            self.shouldMoveBaseViewController = shouldMoveBaseViewController
            self.duration = duration
        }
    }
    
    private let interactiveAnimator = LeftBarInteractiveAnimator()
    private let _config = Config(shouldMoveBaseViewController: true)
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LeftBarDismissAnimator(config: _config)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LeftBarPresentAnimator(config: _config)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
//        return interactor
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
//        return interactor
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
        
        UIView.animate(withDuration: _config.duration, animations: { [_config] in
            fromViewController.view.transform = CGAffineTransform(translationX: -translationX, y: 0)
            toViewController.view.alpha = 1.0
            if _config.shouldMoveBaseViewController {
                toViewController.view.transform = .identity
            }
        }, completion: { completed in
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(completed)
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
        
        UIView.animate(withDuration: _config.duration, animations: { [_config] in
            toViewController.view.transform = .identity
            fromViewController.view.alpha = 0.3
            if _config.shouldMoveBaseViewController {
                fromViewController.view.transform = CGAffineTransform(translationX: translationX, y: 0)
            }
        }, completion: { completed in
            transitionContext.completeTransition(true)
        })
    }
}

final class LeftBarInteractiveAnimator: UIPercentDrivenInteractiveTransition {
}
