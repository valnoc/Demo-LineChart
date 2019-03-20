//
//  LineChartLine+CG.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation
import CoreGraphics

extension LineChart.Line {
    var points: [CGPoint] {
        return zip(x, y).map({ CGPoint(x: $0.0, y: $0.1) })
    }
    
    func path(applying transform: CGAffineTransform) -> CGPath {
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        return path
    }
    
    func boundingRect(for xRange: ClosedRange<CGFloat>) -> CGRect {
        let points = self.points
        let xMin = x.min() ?? 0
        let xMax = x.max() ?? 0
        let xDiff = xMax - xMin
       
        let xMinInRange = CGFloat(xMin + xDiff * Double(xRange.lowerBound))
        let xMaxInRange = CGFloat(xMin + xDiff * Double(xRange.upperBound))
        
        let ysInRange = points
            .filter({ $0.x >= xMinInRange && $0.x <= xMaxInRange })
            .map({ $0.y })
        
        let yMinInRange = ysInRange.min() ?? 0
        let yMaxInRange = ysInRange.max() ?? 0
       
        return CGRect(x: xMinInRange,
                      y: yMinInRange,
                      width: xMaxInRange - xMinInRange,
                      height: yMaxInRange - yMinInRange)
    }
}
