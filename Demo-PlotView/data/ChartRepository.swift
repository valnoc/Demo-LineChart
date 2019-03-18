//
//  ChartRepository.swift
//  Demo-PlotView
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
            
            ///
            do {
                let mock = [
                    LineChart(lines: [
                        LineChart.Line(x: [0, 50, 100, 200, 250, 500, 700],
                                        y: [0, 100, 300, 150, 80, 500, 20],
                                        colorHex: "#FF0000",
                                        name: "line1")
                    ])
                ]
                return mock
            }
            ///
            
            return result
        } catch {
            return []
        }
    }
}
