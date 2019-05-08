//
//  MenuListViewController.swift
//  LeftBarSample
//
//  Created by はるふ on 2019/05/08.
//  Copyright © 2019 はるふ. All rights reserved.
//

import UIKit

final class MenuListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("view did appear")
    }
}
