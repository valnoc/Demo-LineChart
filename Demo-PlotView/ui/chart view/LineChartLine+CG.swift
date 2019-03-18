//
//  LineChartLine+CG.swift
//  Demo-PlotView
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
    
    var path: CGPath {
        let path = CGMutablePath()
        path.addLines(between: points)
        return path
    }
    
    func boundingRect(for xRange: ClosedRange<CGFloat>) -> CGRect {
        let points = self.points
        let lowerIndex = Int(CGFloat(points.count - 1) * xRange.lowerBound)
        let upperIndex = Int(CGFloat(points.count - 1) * xRange.upperBound)
        let pointsInRange = points[lowerIndex...upperIndex]
        
        let xs = pointsInRange.map({ $0.x })
        let xMin = xs.min() ?? 0
        let xMax = xs.max() ?? 0
        
        let ys = pointsInRange.map({ $0.y })
        var yMin = ys.min() ?? 0
        if yMin > 0 { yMin = 0 }
        let yMax = ys.max() ?? 0
       
        return CGRect(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin)
    }
}
