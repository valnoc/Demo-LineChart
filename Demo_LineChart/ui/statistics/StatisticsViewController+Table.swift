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
        tableView.delegate = self
        
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
        cell.selectionStyle = .none
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
        
        cell.selectionStyle = .none
        return cell
    }
    
    func makeNameCell(_ line: LineChart.Line, isEnabled: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.name.rawValue) else {
            return UITableViewCell(frame: .zero)
        }
        
        cell.textLabel?.text = line.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        
        cell.imageView?.image = UIImage(color: UIColor(hex: line.colorHex),
                                        size: CGSize(width: 13, height: 13))
        cell.imageView?.layer.cornerRadius = 3
        cell.imageView?.layer.masksToBounds = true
        
        cell.accessoryType = isEnabled ? .checkmark: .none
        
        return cell
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return chartView.chart.lines.isEmpty ? 0: 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + chartView.chart.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return makeChartCell()
        case 1:
            return makeRangeCell()
        default:
            let index = indexPath.row - 2
            return makeNameCell(chartView.chart.lines[index],
                                isEnabled: chartView.isLineEnabled(at: index))
        }
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = indexPath.row - 2
        if index > -1 {
            chartView.toggleLine(at: index)
            xRangeControl.chartView.toggleLine(at: index)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "FOLLOWERS" }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        if indexPath.row == 0 || indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        }
    }
}
