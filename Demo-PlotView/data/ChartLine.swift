//
//  ChartLine.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class ChartLine {
    let values: [Double]
    let color: UIColor
    let name: String
    
    init(values: [Double],
         colorHex: String,
         name: String) {
        self.values = values
        self.color = UIColor(hex: colorHex)
        self.name = name
    }
}
