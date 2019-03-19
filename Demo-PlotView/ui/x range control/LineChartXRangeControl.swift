//
//  LineChartXRangeControl.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartXRangeControl : UIControl {
    
    var windowMinX: CGFloat = -1
    var windowMaxX: CGFloat = -1
    
    // MARK: - tracking
    enum PanState {
        case none, isChangingMinX, isChangingMaxX, isMoving
    }
    
    var panState: PanState = .none
    var lastPanPoint: CGPoint = .zero
    
    // MARK: - views
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
        
        guard bounds.width > windowView.horizontalBorderWidth * 2 else { return }
        
        if windowMinX < 0,
            windowMaxX < 0 {
            windowMinX = bounds.minX // 0
            windowMaxX = bounds.maxX
        }
        
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
