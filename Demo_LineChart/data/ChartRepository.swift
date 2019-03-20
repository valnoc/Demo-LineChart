//
//  ChartRepository.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation

class ChartRepository {
    func loadCharts() -> [LineChart] {
        do {
            let json = try readJson()
            let result = LineChartMapper().map(from: json)
            
            //  >>>>
            do {
                let mock = [
                    LineChart(lines: [
                        LineChart.Line(x: [0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550],
                                       y: [0, 200, 120, 300, 50, 100, 10,  0,   200, 120, 300, 50],
                                       colorHex: "#FF0000",
                                       name: "line1"),
                        LineChart.Line(x: [0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550],
                                       y: [50, 0, 200, 300, 100, 145, 100,  0,  200, 120, 300, 50],
                                       colorHex: "#00FF00",
                                       name: "line2")
                        ])
                ]
                return mock
            }
            //  <<<<
            
            return result
        } catch {
            return []
        }
    }
}
