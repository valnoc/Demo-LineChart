//
//  LineChartXRangeControl.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartXRangeControl : UIControl {
    
    enum PanState {
        case none, isChangingMinX, isChangingMaxX, isMoving
    }
    
    var windowMinX: CGFloat = 50
    var windowMaxX: CGFloat = 200
    var panState: PanState = .none
    var lastPanPoint: CGPoint = .zero
    
    let chartView: LineChartView
    var windowView: LineChartXRangeWindowView
    
    init(chart: LineChart) {
        self.chartView = LineChartView(chart: chart)
        windowView = LineChartXRangeWindowView()
        super.init(frame: .zero)
        
        chartView.isUserInteractionEnabled = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)

        windowView.isUserInteractionEnabled = false
        windowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(windowView)
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds.insetBy(dx: 0, dy: 3)
        windowView.frame = CGRect(x: windowMinX,
                                   y: 0,
                                   width: windowMaxX - windowMinX,
                                   height: bounds.height)
    }
    
    // MARK: - value
    var value: ClosedRange<CGFloat> {
        let left = windowMinX / bounds.width
        let right = windowMaxX / bounds.width
        return left...right
    }
  

}
