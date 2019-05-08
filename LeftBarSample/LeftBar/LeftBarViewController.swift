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
    
    init(contentViewController: UIViewController) {
        _contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
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
        
        _tapToCloseGestureRecognizer.addTarget(self, action: #selector(didTappedOutside))
        _tapToCloseGestureRecognizer.delegate = self
        view.addGestureRecognizer(_tapToCloseGestureRecognizer)
    }
    
    @objc
    private func didTappedOutside() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LeftBarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == _tapToCloseGestureRecognizer else {
            // ignore except _tapToCloseGestureRecognizer
            return true
        }
        if _contentViewController.view.frame.contains(_tapToCloseGestureRecognizer.location(in: view)) {
            // ignore taps on _contentViewController
            return false
        }
        return true
    }
}
