//
//  LineChartView.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartView: UIView {
    let chart: LineChart
    fileprivate var linesIndexToEnabled: [Int: Bool] = [:]
    fileprivate var xRangePercents: ClosedRange<CGFloat> = 0.0...1.0
    fileprivate let showAxes: Bool
    
    fileprivate var lineLayers: [CAShapeLayer] = []
    fileprivate var yAxisLayer: CAShapeLayer
    
    init(chart: LineChart,
         showAxes: Bool = true) {
        self.chart = chart
        self.showAxes = showAxes
        yAxisLayer = CAShapeLayer()
        super.init(frame: .zero)
        
        for i in 0..<chart.lines.count {
            linesIndexToEnabled[i] = true
        }
        
        backgroundColor = .white
        
        setupAxisLayer()
        setupLineLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - api
    func show(xRangePercents: ClosedRange<CGFloat>) {
        guard xRangePercents.lowerBound >= 0.0,
            xRangePercents.upperBound <= 1.0 else { return }
        self.xRangePercents = xRangePercents
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func toggleLine(at index: Int) {
        guard var value = linesIndexToEnabled[index] else {
            return
        }
        value.toggle()
        linesIndexToEnabled[index] = value
        setNeedsLayout()
        layoutIfNeeded()
    }
    func isLineEnabled(at index: Int) -> Bool {
        guard let value = linesIndexToEnabled[index] else {
            return false
        }
        return value
    }
    
    // MARK: - size
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let chartRect = chart.boundingRect(for: xRangePercents,
                                           includingLinesAt: linesIndexToEnabled
                                            .filter({$0.value == true})
                                            .map({$0.key}))
        
        let xScale = bounds.width / chartRect.width
        let yScale = bounds.height / chartRect.height
        
        let transform = CGAffineTransform(scaleX: xScale, y: -yScale)
            .translatedBy(x: -chartRect.minX, y: -chartRect.minY - chartRect.height)
        
        for (index, (line, sublayer)) in zip(chart.lines, lineLayers).enumerated() {
            sublayer.frame = bounds
            sublayer.path = line.path(applying: transform)
            sublayer.opacity = linesIndexToEnabled[index] == true ? 1: 0
        }
        
        guard showAxes else { return }
        var axisYs: [CGFloat] = []
        
        var axisMaxY = chartRect.maxY + 1
        var axisMaxYLastDigit: CGFloat = 0
        repeat {
            axisMaxY -= 1
            axisMaxYLastDigit = CGFloat(Int(axisMaxY)).truncatingRemainder(dividingBy: 10)
        } while axisMaxYLastDigit != 5 && axisMaxYLastDigit != 0
        
        do {
            var axisYTemp = axisMaxY
            let axisYStep = (axisMaxY - chartRect.minY) / 5
            while axisYTemp >= chartRect.minY {
                axisYs.append(axisYTemp)
                axisYTemp -= axisYStep
            }
        }
        
        yAxisLayer.frame = bounds
        
        let path = CGMutablePath()
        for y in axisYs {
            let affinedY = CGPoint(x: 0, y: y).applying(transform).y
            path.addLines(between: [
                CGPoint(x: 0, y: affinedY),
                CGPoint(x: bounds.width, y: affinedY)
                ])
        }
        yAxisLayer.path = path
    }
    
    // MARK: - lines
    func setupLineLayers() {
        for line in chart.lines {
            let lineLayer = makeLayer(for: line)
            layer.addSublayer(lineLayer)
            lineLayers.append(lineLayer)
        }
    }
    
    func makeLayer(for line: LineChart.Line) -> CAShapeLayer {
        let layer = CAShapeAnimatableLayer()
        layer.lineWidth = 2
        layer.fillColor = nil
        layer.strokeColor = UIColor(hex: line.colorHex).cgColor
        layer.lineJoin = .round
        layer.masksToBounds = true
        return layer
    }

    // MARK: - axis
    func setupAxisLayer() {
        guard showAxes else { return }
        yAxisLayer.lineWidth = 1
        yAxisLayer.strokeColor = UIColor(red: 241.0 / 255.0,
                                        green: 241.0 / 255.0,
                                        blue: 241.0 / 255.0,
                                        alpha: 1).cgColor
        yAxisLayer.fillColor = nil
        layer.addSublayer(yAxisLayer)
    }
}
