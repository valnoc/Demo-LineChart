//
//  StatisticsViewController.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    let tableView: UITableView
    let chartView: LineChartView
    let xRangeControl: XRangeControl
    
    init(chart: LineChart) {
        chartView = LineChartView(chart: chart)
        xRangeControl = XRangeControl(chart: chart)
        tableView = UITableView(frame: .zero, style: .grouped)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        xRangeControl.addTarget(self, action: #selector(onXRangeChanged), for: .valueChanged)
        
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
        
//        do {
//            chartView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(chartView)
//            let constr = [chartView.topAnchor.constraint(equalTo: view.topAnchor),
//                          chartView.leftAnchor.constraint(equalTo: view.leftAnchor),
//                          chartView.rightAnchor.constraint(equalTo: view.rightAnchor),
//                          chartView.heightAnchor.constraint(equalToConstant: 320)]
//            constr.forEach({ $0.isActive = true })
//        }
//
//        do {
//            xRangeControl.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(xRangeControl)
//            let constr = [xRangeControl.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20),
//                          xRangeControl.leftAnchor.constraint(equalTo: view.leftAnchor),
//                          xRangeControl.rightAnchor.constraint(equalTo: view.rightAnchor),
//                          xRangeControl.heightAnchor.constraint(equalToConstant: 44)]
//            constr.forEach({ $0.isActive = true })
//        }
    }
    
    @objc
    func onXRangeChanged(_ sender: XRangeControl) {
        let value = sender.value
        chartView.show(xRangePercents: value)
    }
    
}
