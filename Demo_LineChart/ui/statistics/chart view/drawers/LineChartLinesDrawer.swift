//
//  LineChartLinesDrawer.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 21/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartLinesDrawer {
    fileprivate var lineLayers: [CAShapeLayer] = []
    fileprivate var linesIndexToEnabled: [Int: Bool] = [:]
    
    //MARK: - layout
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
    
    fileprivate func setupLineLayers(chart: LineChart,
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
    
    //MARK: - toggle
    func toggleLine(at index: Int) {
        guard var value = linesIndexToEnabled[index] else {
            return
        }
        guard !( // not the last true
            value == true &&
                enabledLinesIndexes().count == 1
            ) else {
                return
        }
        value.toggle()
        linesIndexToEnabled[index] = value
    }
    
    func isLineEnabled(at index: Int) -> Bool {
        guard let value = linesIndexToEnabled[index] else {
            return false
        }
        return value
    }
    
    func enabledLinesIndexes() -> [Int] {
        return linesIndexToEnabled
            .filter({$0.value == true})
            .map({$0.key})
    }
    
    func enabledLines(_ lines: [LineChart.Line]) -> [LineChart.Line] {
        let indexes = enabledLinesIndexes()
        return lines
            .enumerated()
            .filter({ indexes.contains($0.offset) })
            .map({$0.element})
    }
}
