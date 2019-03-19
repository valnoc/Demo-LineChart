//
//  LineChartXRangeControl+Tracking.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 19/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

extension XRangeControl {
    
    // MARK: - pan
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        
        let borderWidth = windowView.horizontalBorderWidth
        let borderCenterX = borderWidth / 2
        
        let leftXArea = CGRect(x: rangeLeftX + borderCenterX - 22, y: 0, width: 44, height: bounds.height)
        let rightXArea = CGRect(x: rangeRightX - borderCenterX - 22, y: 0, width: 44, height: bounds.height)
        let insideArea = CGRect(x: rangeLeftX + borderWidth,
                                y: 0,
                                width: rangeRightX - rangeLeftX - borderWidth * 2,
                                height: bounds.height)
        
        switch (leftXArea.contains(point), insideArea.contains(point), rightXArea.contains(point)) {
        case (true, _, false):
            trackingState = .isChangingLeftX
        
        case (false, _, true):
            trackingState = .isChangingRightX
            
        case (false, true, false):
            trackingState = .isMovingRange
            
        case (true, false, true):
            if leftXArea.minX < 0 {
                trackingState = .isChangingRightX
            
            } else if rightXArea.maxX > bounds.maxX {
                trackingState = .isChangingLeftX
            
            } else if abs(point.x - rangeLeftX) < abs(point.x - rangeRightX) {
                trackingState = .isChangingLeftX
            } else {
                trackingState = .isChangingRightX
            }
            
        case (true, true, true):
            trackingState = .isMovingRange
            
        case (false, false, false):
            trackingState = .none
        }
        
        lastTrackingPoint = point
        return trackingState != .none
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        
        let xDiff = point.x - lastTrackingPoint.x
        
        let leftXMin: CGFloat = 0
        let leftXMax: CGFloat = rangeRightX - windowView.horizontalBorderWidth * 2
        
        let rightXMin: CGFloat = rangeLeftX + windowView.horizontalBorderWidth * 2
        let rightXMax: CGFloat = bounds.width
        
        let newLeftX = rangeLeftX + xDiff
        let newRightX = rangeRightX + xDiff
        
        switch trackingState {
        case .isChangingLeftX:
            if newLeftX < leftXMin {
                rangeLeftX = leftXMin
                
            } else if newLeftX > leftXMax {
                rangeLeftX = leftXMax
                
            } else {
                rangeLeftX = newLeftX
            }
            
        case .isChangingRightX:
            if newRightX < rightXMin {
                rangeRightX = rightXMin
                
            } else if newRightX > rightXMax {
                rangeRightX = rightXMax
                
            } else {
                rangeRightX = newRightX
            }
            
        case .isMovingRange:
            if newLeftX >= leftXMin, newLeftX <= leftXMax,
                newRightX >= rightXMin, newRightX <= rightXMax {
                rangeLeftX = newLeftX
                rangeRightX = newRightX
            }
            
        default:
            break
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        lastTrackingPoint = point
        sendActions(for: .valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        trackingState = .none
        sendActions(for: .valueChanged)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        trackingState = .none
        sendActions(for: .valueChanged)
    }
    
}
