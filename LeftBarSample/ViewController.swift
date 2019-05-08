//
//  ViewController.swift
//  LeftBarSample
//
//  Created by はるふ on 2019/05/08.
//  Copyright © 2019 はるふ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var button: UIButton!
    
    let animator = LeftBarAnimationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.addTarget(self, action: #selector(didTappedButton), for: .touchUpInside)
    }
    
    @objc
    private func didTappedButton() {
        let viewController = LeftBarViewController(contentViewController: MenuListViewController(nibName: nil, bundle: nil))
        viewController.transitioningDelegate = animator
        self.present(viewController, animated: true, completion: nil)
    }

}

