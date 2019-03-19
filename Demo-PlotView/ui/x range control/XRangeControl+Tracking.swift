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
        
        let leftXArea = CGRect(x: rangeLeftX - 22, y: 0, width: 44, height: bounds.height)
        let rightXArea = CGRect(x: rangeRightX - 22, y: 0, width: 44, height: bounds.height)
        let insideArea = CGRect(x: rangeLeftX, y: 0, width: rangeRightX - rangeLeftX, height: bounds.height)
        
        if leftXArea.contains(point) {
            trackingState = .isChangingMinX
            
        } else if rightXArea.contains(point) {
            trackingState = .isChangingMaxX
            
        } else if insideArea.contains(point) {
            trackingState = .isMoving
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
        case .isChangingMinX:
            if newLeftX < leftXMin {
                rangeLeftX = leftXMin
                
            } else if newLeftX > leftXMax {
                rangeLeftX = leftXMax
                
            } else {
                rangeLeftX = newLeftX
            }
            
        case .isChangingMaxX:
            if newRightX < rightXMin {
                rangeRightX = rightXMin
                
            } else if newRightX > rightXMax {
                rangeRightX = rightXMax
                
            } else {
                rangeRightX = newRightX
            }
            
        case .isMoving:
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
