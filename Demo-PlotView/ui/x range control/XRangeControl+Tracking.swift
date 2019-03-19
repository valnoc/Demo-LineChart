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
        
        let minXArea = CGRect(x: rangeMinX - 22, y: 0, width: 44, height: bounds.height)
        let maxXArea = CGRect(x: rangeMaxX - 22, y: 0, width: 44, height: bounds.height)
        let insideArea = CGRect(x: rangeMinX, y: 0, width: rangeMaxX - rangeMinX, height: bounds.height)
        
        if minXArea.contains(point) {
            trackingState = .isChangingMinX
            
        } else if maxXArea.contains(point) {
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
        
        let windowMinXPossibleMin: CGFloat = 0
        let windowMinXPossibleMax: CGFloat = rangeMaxX - windowView.horizontalBorderWidth * 2
        
        let windowMaxXPossibleMin: CGFloat = rangeMinX + windowView.horizontalBorderWidth * 2
        let windowMaxXPossibleMax: CGFloat = bounds.width
        
        let newMinX = rangeMinX + xDiff
        let newMaxX = rangeMaxX + xDiff
        
        switch trackingState {
        case .isChangingMinX:
            if newMinX < windowMinXPossibleMin {
                rangeMinX = windowMinXPossibleMin
                
            } else if newMinX > windowMinXPossibleMax {
                rangeMinX = windowMinXPossibleMax
                
            } else {
                rangeMinX = newMinX
            }
            
        case .isChangingMaxX:
            if newMaxX < windowMaxXPossibleMin {
                rangeMaxX = windowMaxXPossibleMin
                
            } else if newMaxX > windowMaxXPossibleMax {
                rangeMaxX = windowMaxXPossibleMax
                
            } else {
                rangeMaxX = newMaxX
            }
            
        case .isMoving:
            if newMinX >= windowMinXPossibleMin, newMinX <= windowMinXPossibleMax,
                newMaxX >= windowMaxXPossibleMin, newMaxX <= windowMaxXPossibleMax {
                rangeMinX = newMinX
                rangeMaxX = newMaxX
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
