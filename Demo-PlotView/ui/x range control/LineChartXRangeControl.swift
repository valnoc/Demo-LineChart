//
//  LineChartXRangeControl.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartXRangeControl : UIControl {
    
    let chartView: LineChartView
    
    init(chart: LineChart) {
        self.chartView = LineChartView(chart: chart)
        super.init(frame: .zero)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
}
