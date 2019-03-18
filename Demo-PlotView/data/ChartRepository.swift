//
//  ChartRepository.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation

class ChartRepository {
    func loadCharts() -> [LinedChart] {
        do {
            let json = try readJson()
            let result = LinedChartMapper().map(from: json)
            return result
        } catch {
            return []
        }
    }
}
