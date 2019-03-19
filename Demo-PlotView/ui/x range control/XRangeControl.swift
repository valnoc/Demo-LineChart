//
//  LineChartXRangeControl.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class XRangeControl : UIControl {
    
    var rangeLeftX: CGFloat = -1
    var rangeRightX: CGFloat = -1
    
    // MARK: - tracking
    enum TrackingState {
        case none, isChangingMinX, isChangingMaxX, isMoving
    }
    
    var trackingState: TrackingState = .none
    var lastTrackingPoint: CGPoint = .zero
    
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
        
        if rangeLeftX < 0,
            rangeRightX < 0 {
            rangeLeftX = bounds.minX // 0
            rangeRightX = bounds.maxX
        }
        
        chartView.frame = bounds.insetBy(dx: 0, dy: 3)
        windowView.frame = CGRect(x: rangeLeftX,
                                   y: 0,
                                   width: rangeRightX - rangeLeftX,
                                   height: bounds.height)
    }
    
    // MARK: - value
    var value: ClosedRange<CGFloat> {
        let left = rangeLeftX / bounds.width
        let right = rangeRightX / bounds.width
        return left...right
    }
  

}
