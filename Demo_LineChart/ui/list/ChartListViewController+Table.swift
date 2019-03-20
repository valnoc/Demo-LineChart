//
//  ChartListViewController+Table.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 20/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

extension ChartListViewController {
    enum Cell: String {
        case chart
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.chart.rawValue)
    }
    
    func makeChartCell(at index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.chart.rawValue) else {
            return UITableViewCell(frame: .zero)
        }
        cell.textLabel?.text = "Chart #\(index + 1)"
        return cell
    }
}

extension ChartListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return makeChartCell(at: indexPath.row)
    }
}

extension ChartListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let chart = charts[indexPath.row]
        
        let vc = StatisticsViewController(chart: chart)
        navigationController?.pushViewController(vc, animated: true)
    }
}
