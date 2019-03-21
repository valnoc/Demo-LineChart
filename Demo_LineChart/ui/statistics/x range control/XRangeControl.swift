//
//  XRangeControl.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class XRangeControl : UIControl {
    
    // MARK: - value
    var value: ClosedRange<CGFloat> {
        let left = leftX / bounds.width
        let right = rightX / bounds.width
        return left...right
    }
    var leftX: CGFloat = -1
    var rightX: CGFloat = -1
    
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
        self.chartView = LineChartView(chart: chart, showAxes: false)
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
        guard bounds.width > minWindowWidth() else { return }
        
        checkAndFixRangeLeftRightXValues()
        
        windowView.frame = makeWindowFrame()
        
        let chartFrame = makeChartFrame()
        chartView.frame = chartFrame
        
        overlay.frame = chartFrame
        overlay.path = makeOverlayPath()
    }

    func addAllSubviews() {
        chartView.isUserInteractionEnabled = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)

        overlay.opacity = 0.9
        overlay.fillRule = .evenOdd
        overlay.fillColor = UIColor(red: 245.0/255.0, green: 247.0/255.0, blue: 249.0/255.0, alpha: 1).cgColor
        layer.addSublayer(overlay)
        
        windowView.isUserInteractionEnabled = false
        windowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(windowView)
    }
    
    // MARK: - calculations
    func checkAndFixRangeLeftRightXValues() {
        if leftX < 0, rightX < 0 {
            leftX = bounds.minX // 0
            rightX = bounds.maxX
        }
        
        if rightX > bounds.maxX {
            rightX = bounds.maxX
        }
        
        let maxLeftX = rightX - minWindowWidth()
        if leftX > maxLeftX { leftX = maxLeftX }
    }
    
    func makeChartFrame() -> CGRect {
        return bounds.insetBy(dx: 0, dy: 3)
    }
    
    func makeOverlayPath() -> CGPath {
        let chartFrame = makeChartFrame()
        let windowFrame = makeWindowFrame()
        
        let path = CGMutablePath()
        path.addRect(
            CGRect(x: 0,
                   y: 0,
                   width: chartFrame.width,
                   height: chartFrame.height)
        )
        path.addRect(
            CGRect(x: windowFrame.minX,
                   y: 0,
                   width: windowFrame.width,
                   height: chartFrame.height)
        )
        return path
    }
    
    func makeWindowFrame() -> CGRect {
        return CGRect(x: leftX,
                      y: 0,
                      width: rightX - leftX,
                      height: bounds.height)
    }
    
    func minWindowWidth() -> CGFloat {
        return windowView.horizontalBorder * 2
    }
}
