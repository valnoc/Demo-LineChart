//
//  LineChartLinesRenderer.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 21/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartLinesRenderer {
    fileprivate var lineLayers: [CAShapeLayer] = []
    var linesIndexToEnabled: [Int: Bool] = [:]
    
    func layoutLines(chart: LineChart,
                     viewLayer: CALayer,
                     chartRect: CGRect,
                     affine: CGAffineTransform) {
        if lineLayers.count != chart.lines.count {
            setupLineLayers(chart: chart,
                            viewLayer: viewLayer)
        }
        
        for (index, (line, sublayer)) in zip(chart.lines, lineLayers).enumerated() {
            sublayer.frame = viewLayer.bounds
            sublayer.path = line.path(applying: affine)
            sublayer.opacity = linesIndexToEnabled[index] == true ? 1: 0
        }
    }
    
    func setupLineLayers(chart: LineChart,
                         viewLayer: CALayer) {
        lineLayers.forEach({ $0.removeFromSuperlayer() })
        linesIndexToEnabled.removeAll()
        
        for line in chart.lines {
            let lineLayer = makeLayer(for: line)
            viewLayer.addSublayer(lineLayer)
            lineLayers.append(lineLayer)
        }
        
        for i in 0..<chart.lines.count {
            linesIndexToEnabled[i] = true
        }
    }
    
    func makeLayer(for line: LineChart.Line) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineWidth = 2
        layer.fillColor = nil
        layer.strokeColor = UIColor(hex: line.colorHex).cgColor
        layer.lineJoin = .round
        layer.masksToBounds = true
        
        let animation = CABasicAnimation()
        animation.duration = CATransaction.animationDuration() / 2
        animation.timingFunction = CATransaction.animationTimingFunction()
        layer.actions = ["path": animation]
        return layer
    }
}
