//
//  LineChartXRangeControl.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartXRangeControl : UIControl {
    
    let windowLeftX: CGFloat = 50
    let windowRightX: CGFloat = 200
    
    let chartView: LineChartView
    var windowView: LineChartXRangeWindowView
    
    init(chart: LineChart) {
        self.chartView = LineChartView(chart: chart)
        windowView = LineChartXRangeWindowView()
        super.init(frame: .zero)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)

        windowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(windowView)
        
        backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds.insetBy(dx: 0, dy: 3)
        windowView.frame = CGRect(x: windowLeftX,
                                   y: 0,
                                   width: windowRightX - windowLeftX,
                                   height: bounds.height)
    }
}
