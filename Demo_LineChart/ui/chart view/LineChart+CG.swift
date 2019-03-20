//
//  LineChart+CG.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation
import CoreGraphics

extension LineChart {
    func boundingRect(for xRange: ClosedRange<CGFloat>) -> CGRect {
        let rects = lines.map({ $0.boundingRect(for: xRange) })
        
        let xMin = rects.map({ $0.minX }).min() ?? 0
        let xMax = rects.map({ $0.maxX }).max() ?? 0
        
        let yMin = rects.map({ $0.minY }).min() ?? 0
        let yMax = rects.map({ $0.maxY }).max() ?? 0
        
        return CGRect(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin)
    }
}
