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
        var points = self.points
        
        let path = CGMutablePath()
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            points = Array(points.dropFirst())
        }
        
        for p in points {
            path.move(to: p)
        }
        
        return path
    }
}
