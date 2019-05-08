//
//  LeftBarViewController.swift
//  LeftBarSample
//
//  Created by はるふ on 2019/05/08.
//  Copyright © 2019 はるふ. All rights reserved.
//

import UIKit

final class LeftBarViewController: UIViewController {
    private let _contentViewController: UIViewController
    let coverRatio: CGFloat = 0.6
    private let _tapToCloseGestureRecognizer = UITapGestureRecognizer()
    private lazy var _panToCloseGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }()
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
        
        // setup shadow for content
        // seealso: https://ringsbell.blog.fc2.com/blog-entry-494.html
        _contentViewController.view.layer.masksToBounds = false
        _contentViewController.view.layer.shadowOffset = CGSize(width: 4, height: 0)
        _contentViewController.view.layer.shadowOpacity = 0.8
        _contentViewController.view.layer.shadowRadius = 8
        _contentViewController.view.layer.shadowPath = UIBezierPath(rect: _contentViewController.view.bounds).cgPath
        
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
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        _animationController.interactiveDismissAnimator.finish()
    }
    
    func startToDismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
    @objc
    private func didTappedOutside() {
        dismiss(animated: true, completion: nil)
    }
    
    private var _isLastDirectionDismiss: Bool = true
    private var _lastTranslation: CGPoint = .zero
    @objc
    private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        let interactiveAnimator = _animationController.interactiveDismissAnimator

        switch gestureRecognizer.state {
        case .began:
            gestureRecognizer.setTranslation(.zero, in: view)
            _lastTranslation = .zero
            self.startToDismiss(animated: true, completion: nil)
        case .changed:
            let translation = gestureRecognizer.translation(in: view)
            let percentage = max(0, -translation.x / (view.bounds.width * coverRatio))
            interactiveAnimator.update(percentage)
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
