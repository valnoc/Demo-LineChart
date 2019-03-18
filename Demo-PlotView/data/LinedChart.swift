//
//  Chart.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation

struct LinedChart {
    let lines: [Line]
    
    struct Line {
        let x: [Double]
        let y: [Double]
        let colorHex: String
        let name: String
    }
}
