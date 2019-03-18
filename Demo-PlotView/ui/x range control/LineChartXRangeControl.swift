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
    
    // MARK: - value
    var value: ClosedRange<CGFloat> {
        let left = windowMinX / bounds.width
        let right = windowMaxX / bounds.width
        return left...right
    }
    
    // MARK: - pan
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        
        let minXArea = CGRect(x: windowMinX - 22, y: 0, width: 44, height: bounds.height)
        let maxXArea = CGRect(x: windowMaxX - 22, y: 0, width: 44, height: bounds.height)
        let insideArea = CGRect(x: windowMinX, y: 0, width: windowMaxX - windowMinX, height: bounds.height)
        
        if minXArea.contains(point) {
            panState = .isChangingMinX
        
        } else if maxXArea.contains(point) {
            panState = .isChangingMaxX
        
        } else if insideArea.contains(point) {
            panState = .isMoving
        }

        lastPanPoint = point
        return panState != .none
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        
        let xDiff = point.x - lastPanPoint.x
        
        let windowMinXPossibleMin: CGFloat = 0
        let windowMinXPossibleMax: CGFloat = windowMaxX - windowView.horizontalBorderWidth * 2
        
        let windowMaxXPossibleMin: CGFloat = windowMinX + windowView.horizontalBorderWidth * 2
        let windowMaxXPossibleMax: CGFloat = bounds.width
        
        let newMinX = windowMinX + xDiff
        let newMaxX = windowMaxX + xDiff
        
        switch panState {
        case .isChangingMinX:
            if newMinX < windowMinXPossibleMin {
                windowMinX = windowMinXPossibleMin
            
            } else if newMinX > windowMinXPossibleMax {
                windowMinX = windowMinXPossibleMax
                
            } else {
                windowMinX = newMinX
            }
            
        case .isChangingMaxX:
            if newMaxX < windowMaxXPossibleMin {
                windowMaxX = windowMaxXPossibleMin
                
            } else if newMaxX > windowMaxXPossibleMax {
                windowMaxX = windowMaxXPossibleMax
                
            } else {
                windowMaxX = newMaxX
            }
            
        case .isMoving:
            if newMinX >= windowMinXPossibleMin, newMinX <= windowMinXPossibleMax,
                newMaxX >= windowMaxXPossibleMin, newMaxX <= windowMaxXPossibleMax {
                windowMinX = newMinX
                windowMaxX = newMaxX
            }
            
        default:
            break
        }
        
        setNeedsLayout()
        layoutIfNeeded()

        lastPanPoint = point
        sendActions(for: .valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        panState = .none
        sendActions(for: .valueChanged)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        panState = .none
        sendActions(for: .valueChanged)
    }
}
