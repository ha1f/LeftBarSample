//
//  LeftBarViewController.swift
//  LeftBarSample
//
//  Created by はるふ on 2019/05/08.
//  Copyright © 2019 はるふ. All rights reserved.
//

import UIKit

final class LeftBarViewController: UIViewController {
    /// Percentage to cover screen
    let coverRatio: CGFloat = 0.6
    
    /// ViewController to controll content
    private let _contentViewController: UIViewController
    
    var contentView: UIView {
        return _contentViewController.view
    }
    
    /// A gesture recognizer to close by tapping outside
    private let _tapToCloseGestureRecognizer = UITapGestureRecognizer()
    
    /// A gesture recognizer to close by swiping
    private let _panToCloseGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }()
    
    /// last recognized direction of pan gesture
    private var _isLastDirectionDismiss: Bool = true
    
    /// previous translation of pan gesture
    private var _lastTranslation: CGPoint = .zero
    
    private let _animationController = LeftBarAnimationController()
    
    init(contentViewController: UIViewController) {
        _contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = _animationController
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        
        // Setup content ViewController
        addChild(_contentViewController)
        view.addSubview(_contentViewController.view)
        _contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            _contentViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            _contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            _contentViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: coverRatio)
            ])
        _contentViewController.didMove(toParent: self)
        
        // Setup shadow for content.
        // Note that we set shadowOpacity in animator.
        // seealso: https://ringsbell.blog.fc2.com/blog-entry-494.html
        _contentViewController.view.layer.masksToBounds = false
        _contentViewController.view.layer.shadowOffset = CGSize(width: 4, height: 0)
        _contentViewController.view.layer.shadowRadius = 6
        // A hack to spped up. We also update in viewDidLayoutSubviews.
        _contentViewController.view.layer.shadowPath = UIBezierPath(rect: _contentViewController.view.bounds).cgPath
        
        // Setup gesture recognizers
        _panToCloseGestureRecognizer.addTarget(self, action: #selector(handlePanGestureRecognizer(_:)))
        view.addGestureRecognizer(_panToCloseGestureRecognizer)
        
        _tapToCloseGestureRecognizer.addTarget(self, action: #selector(didTappedOutside))
        _tapToCloseGestureRecognizer.delegate = self
        view.addGestureRecognizer(_tapToCloseGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // update shadow for content
        _contentViewController.view.layer.shadowPath = UIBezierPath(rect: _contentViewController.view.bounds).cgPath
    }
    
    /// Dismiss ViewController without interaction
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        _animationController.interactiveDismissAnimator.finish()
    }
    
    /// Start interactive dismiss
    func startToDismiss() {
        super.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTappedOutside() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        let interactiveAnimator = _animationController.interactiveDismissAnimator

        switch gestureRecognizer.state {
        case .began:
            gestureRecognizer.setTranslation(.zero, in: view)
            _lastTranslation = .zero
            self.startToDismiss()
        case .changed:
            let translation = gestureRecognizer.translation(in: view)
            let percentage = max(0, -translation.x / (view.bounds.width * coverRatio))
            
            // update for percentage of interactive transition
            interactiveAnimator.update(percentage)
            
            // recognize
            if translation.x < _lastTranslation.x {
                _isLastDirectionDismiss = true
            } else if translation.x > _lastTranslation.x {
                _isLastDirectionDismiss = false
            }
            _lastTranslation = translation
        case .ended:
            if _isLastDirectionDismiss {
                interactiveAnimator.finish()
            } else {
                interactiveAnimator.cancel()
            }
        case .cancelled, .failed:
            interactiveAnimator.cancel()
        default:
            interactiveAnimator.cancel()
        }
    }
}

extension LeftBarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == _tapToCloseGestureRecognizer {
            if _contentViewController.view.frame.contains(_tapToCloseGestureRecognizer.location(in: view)) {
                // ignore taps on _contentViewController
                return false
            }
        }
        return true
    }
}
