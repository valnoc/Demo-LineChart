//
//  LineChartXRangeControl.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class XRangeControl : UIControl {
    
    // MARK: - value
    var value: ClosedRange<CGFloat> {
        let left = rangeLeftX / bounds.width
        let right = rangeRightX / bounds.width
        return left...right
    }
    var rangeLeftX: CGFloat = -1
    var rangeRightX: CGFloat = -1
    
    // MARK: - tracking
    enum TrackingState {
        case none, isChangingLeftX, isChangingRightX, isMovingRange
    }
    var trackingState: TrackingState = .none
    var lastTrackingPoint: CGPoint = .zero
    
    // MARK: - views
    let chartView: LineChartView
    let windowView: XRangeControlWindow
    let overlay: CAShapeLayer
    
    init(chart: LineChart) {
        self.chartView = LineChartView(chart: chart)
        windowView = XRangeControlWindow()
        overlay = CAShapeLayer()
        
        super.init(frame: .zero)
        
        addAllSubviews()
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > windowView.horizontalBorderWidth * 2 else { return }
        
        if rangeLeftX < 0,
            rangeRightX < 0 {
            rangeLeftX = bounds.minX // 0
            rangeRightX = bounds.maxX
        }
        
        let chartFrame = makeChartFrame()
        chartView.frame = chartFrame
        windowView.frame = CGRect(x: rangeLeftX,
                                   y: 0,
                                   width: rangeRightX - rangeLeftX,
                                   height: bounds.height)
        
        overlay.frame = chartFrame
        overlay.path = makeOverlayPath()
    }

    func addAllSubviews() {
        chartView.isUserInteractionEnabled = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)

        overlay.backgroundColor = nil
        overlay.opacity = 0.9
        overlay.fillRule = .evenOdd
        overlay.fillColor = UIColor(red: 245.0/255.0, green: 247.0/255.0, blue: 249.0/255.0, alpha: 1).cgColor
        layer.addSublayer(overlay)
        
        windowView.isUserInteractionEnabled = false
        windowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(windowView)
    }
    
    // MARK: - calculations
    func makeChartFrame() -> CGRect {
        return bounds.insetBy(dx: 0, dy: 3)
    }
    
    func makeOverlayPath() -> CGPath {
        let chartFrame = makeChartFrame()
        
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: chartFrame.width, height: chartFrame.height))
        path.addRect(CGRect(x: rangeLeftX, y: 0, width: rangeRightX - rangeLeftX, height: chartFrame.height))
        return path
    }
}
