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
            
            //  >>>>
            do {
                let mock = [
                    LineChart(lines: [
                        LineChart.Line(x: [0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550],
                                        y: [0, 100, 300, 150, 80, 500, 20, 300, 700, 50,  150, 10],
                                        colorHex: "#FF0000",
                                        name: "line1")
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
