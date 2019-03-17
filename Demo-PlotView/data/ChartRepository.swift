//
//  ChartRepository.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation

class ChartRepository {
    func loadCharts() -> [Chart] {
        do {
            let json = try readJson()
            let result = ChartMapper().map(from: json)
            return result
        } catch {
            return []
        }
    }
}
