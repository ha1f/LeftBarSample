//
//  MenuListViewController.swift
//  LeftBarSample
//
//  Created by はるふ on 2019/05/08.
//  Copyright © 2019 はるふ. All rights reserved.
//

import UIKit

final class MenuListCell: UITableViewCell {
    static let reuseIdentifier = String(describing: self)
}

final class MenuListViewController: UIViewController {
    let tableView = UITableView()
    let items: [String] = ["アカウント", "設定"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        tableView.tableFooterView = UIView()
        tableView.register(MenuListCell.self, forCellReuseIdentifier: MenuListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension MenuListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuListCell.reuseIdentifier, for: indexPath) as? MenuListCell ?? MenuListCell()
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

extension MenuListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
