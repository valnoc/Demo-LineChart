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
         color: UIColor,
         name: String) {
        self.values = values
        self.color = color
        self.name = name
    }
}
