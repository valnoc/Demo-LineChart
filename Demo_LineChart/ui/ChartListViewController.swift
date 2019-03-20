//
//  ChartListViewController.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 20/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class ChartListViewController: UIViewController {
    
    let tableView: UITableView
    let charts: [LineChart]
    
    init(charts: [LineChart]) {
        self.charts = charts
        tableView = UITableView(frame: .zero, style: .grouped)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Charts"
        view.backgroundColor = .white
        
        setupTableView()
        do {
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            let constr = [tableView.topAnchor.constraint(equalTo: view.topAnchor),
                          tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                          tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                          tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
            constr.forEach({ $0.isActive = true })
        }
    }
    
}
