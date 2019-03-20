//
//  StatisticsViewController+Table.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 20/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

extension StatisticsViewController {
    enum Cell: String {
        case chart, range, name
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.chart.rawValue)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.range.rawValue)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.name.rawValue)
    }
    
    func makeChartCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.chart.rawValue) else {
            return UITableViewCell(frame: .zero)
        }
        let contentView = cell.contentView
        
        guard chartView.superview != contentView else { return cell }
        chartView.removeFromSuperview()
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chartView)
        let constr = [chartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
                      chartView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
                      chartView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
                      chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
                      chartView.heightAnchor.constraint(equalToConstant: 320)]
        constr.forEach({ $0.isActive = true })
        return cell
    }
    
    func makeRangeCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.range.rawValue) else {
            return UITableViewCell(frame: .zero)
        }
        let contentView = cell.contentView
        
        guard xRangeControl.superview != contentView else { return cell }
        xRangeControl.removeFromSuperview()
        
        xRangeControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(xRangeControl)
        let constr = [xRangeControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
                      xRangeControl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
                      xRangeControl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
                      xRangeControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
                      xRangeControl.heightAnchor.constraint(equalToConstant: 44)]
        constr.forEach({ $0.isActive = true })
        return cell
    }
    
    func makeNameCell(_ line: LineChart.Line) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.name.rawValue) else {
            return UITableViewCell(frame: .zero)
        }

        cell.textLabel?.text = line.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        
        cell.imageView?.image = UIImage(color: UIColor(hex: line.colorHex),
                                        size: CGSize(width: 13, height: 13))
        cell.imageView?.layer.cornerRadius = 3
        cell.imageView?.layer.masksToBounds = true
        
        return cell
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return chartView.chart.lines.isEmpty ? 0: 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 + chartView.chart.lines.count }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return makeChartCell()
            case 1:
                return makeRangeCell()
            default:
                return makeNameCell(chartView.chart.lines[indexPath.row - 2])
            }
        default:
            break
        }
        return UITableViewCell(frame: .zero)
    }
}
