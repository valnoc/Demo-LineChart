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
        case notChanging
        case isChangingLeftBorder(lastPoint: CGPoint)
        case isChangingRightBorder(lastPoint: CGPoint)
        case isMoving(lastPoint: CGPoint)
    }
    
    var windowMinX: CGFloat = 50
    var windowMaxX: CGFloat = 200
    var panState: PanState = .none
    
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
        
        backgroundColor = .yellow
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
    
    // MARK: - move
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        
        let leftBorderArea = CGRect(x: windowMinX - 22, y: 0, width: 44, height: bounds.height)
        let rightBorderArea = CGRect(x: windowMaxX - 22, y: 0, width: 44, height: bounds.height)
        let windowArea = CGRect(x: windowMinX, y: 0, width: windowMaxX - windowMinX, height: bounds.height)
        
        if leftBorderArea.contains(point) {
            panState = .isChangingLeftBorder(lastPoint: point)
            return true
        
        } else if rightBorderArea.contains(point) {
            panState = .isChangingRightBorder(lastPoint: point)
            return true
        
        } else if windowArea.contains(point) {
            panState = .isMoving(lastPoint: point)
            return true
        }
        
        return false
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        
        switch panState {
        case .isChangingLeftBorder(let prevPoint):
            let diff = point.x - prevPoint.x
            windowMinX += diff
            panState = .isChangingLeftBorder(lastPoint: point)
            
        case .isChangingRightBorder(let prevPoint):
            let diff = point.x - prevPoint.x
            windowMaxX += diff
            panState = .isChangingRightBorder(lastPoint: point)
            
        case .isMoving(let prevPoint):
            let diff = point.x - prevPoint.x
            windowMinX += diff
            windowMaxX += diff
            panState = .isChangingLeftBorder(lastPoint: point)
            
        default:
            break
        }
        
        setNeedsLayout()
        windowView.setNeedsDisplay()
        layoutIfNeeded()
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        panState = .notChanging
    }
    
    override func cancelTracking(with event: UIEvent?) {
        panState = .notChanging
    }
}
