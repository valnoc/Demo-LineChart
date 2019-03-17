//
//  Chart.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation

class Chart {
    let x: [TimeInterval]
    let lines: [ChartLine]
    
    init(x: [TimeInterval],
         lines: [ChartLine]) {
        self.x = x
        self.lines = lines
    }
}
