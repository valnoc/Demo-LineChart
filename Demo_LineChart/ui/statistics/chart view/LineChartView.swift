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
    fileprivate var prevYAxisLayer: CAShapeLayer
    fileprivate var prevMaxYOfAxis: CGFloat
    
    init(chart: LineChart,
         showAxes: Bool = true) {
        self.chart = chart
        self.showAxes = showAxes
        
        yAxisLayer = CAShapeLayer()
        prevYAxisLayer = CAShapeLayer()
        prevMaxYOfAxis = 0
        super.init(frame: .zero)
        
        for i in 0..<chart.lines.count {
            linesIndexToEnabled[i] = true
        }
        
        backgroundColor = .white
        
        layer.masksToBounds = true
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
        guard !( // not the last true
            value == true &&
            linesIndexToEnabled.map({$0.value}).filter({$0 == true}).count == 1
            ) else {
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
        
        let affine = CGAffineTransform(scaleX: xScale, y: -yScale)
            .translatedBy(x: -chartRect.minX, y: -chartRect.minY - chartRect.height)
        
        for (index, (line, sublayer)) in zip(chart.lines, lineLayers).enumerated() {
            sublayer.frame = bounds
            sublayer.path = line.path(applying: affine)
            sublayer.opacity = linesIndexToEnabled[index] == true ? 1: 0
        }
        
        guard showAxes else { return }
        var directionFraction: CGFloat = 1.0
        if prevMaxYOfAxis > chartRect.maxY {
           directionFraction = 1.5
        } else if prevMaxYOfAxis < chartRect.maxY {
           directionFraction = 0.5
        }
        guard directionFraction != 1.0 else {
            return
        }

        prevYAxisLayer.removeFromSuperlayer()
        prevYAxisLayer = yAxisLayer
        yAxisLayer = makeYAxisLayer(chartRect: chartRect, affine: affine)
        
        yAxisLayer.opacity = 0.0
        var yAxisPosition = yAxisLayer.position
        yAxisPosition.y = yAxisPosition.y * directionFraction
        yAxisLayer.position = yAxisPosition
        yAxisPosition.y = yAxisLayer.frame.height / 2
        
        var prevYAxisPosition = prevYAxisLayer.position
        prevYAxisPosition.y = prevYAxisPosition.y * (2 - directionFraction)
        
        prevMaxYOfAxis = chartRect.maxY
        
        let animation = CABasicAnimation()
        animation.duration = CATransaction.animationDuration() / 2
        animation.timingFunction = CATransaction.animationTimingFunction()
        prevYAxisLayer.actions = ["position": animation,
                                  "opacity": animation]
        
        let animationNew = CABasicAnimation()
        animation.duration = CATransaction.animationDuration() / 4
        animation.timingFunction = CATransaction.animationTimingFunction()
        yAxisLayer.actions = ["position": animationNew,
                              "opacity": animationNew]
        
        layer.insertSublayer(yAxisLayer, below: lineLayers.first)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) { [weak self] in
            guard let __self = self else { return }
            __self.prevYAxisLayer.opacity = 0.0
            __self.prevYAxisLayer.position = prevYAxisPosition
            __self.yAxisLayer.opacity = 1.0
            __self.yAxisLayer.position = yAxisPosition
        }
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

    // MARK: - axis
    func makeYAxisLayer(chartRect: CGRect, affine: CGAffineTransform) -> CAShapeLayer {
        let axisLayer = CAShapeLayer()
        axisLayer.lineWidth = 1
        axisLayer.strokeColor = UIColor(red: 241.0 / 255.0,
                                         green: 241.0 / 255.0,
                                         blue: 241.0 / 255.0,
                                         alpha: 1).cgColor
        axisLayer.fillColor = nil
        axisLayer.masksToBounds = true

        //
        let axisMaxYTopOffset = (13 + 5 * 2) * chartRect.height / bounds.height
        
        var axisYs: [CGFloat] = []
        
        var axisMaxY = chartRect.maxY + 1 - axisMaxYTopOffset
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
            axisYs.append(chartRect.minY)
        }
        
        axisLayer.frame = bounds
        
        let path = CGMutablePath()
        for y in axisYs {
            let affinedY = CGPoint(x: 0, y: y).applying(affine).y
            path.addLines(between: [
                CGPoint(x: 0, y: affinedY),
                CGPoint(x: bounds.width, y: affinedY)
                ])

            let labelLayer = CATextLayer()
            labelLayer.fontSize = 13
            labelLayer.string = "\(Int(y))"
            labelLayer.foregroundColor = UIColor(red: 144.0 / 255.0,
                                                 green: 150 / 255.0,
                                                 blue: 156 / 255.0,
                                                 alpha: 1).cgColor
            labelLayer.frame = CGRect(x: 0, y: affinedY - 13 - 5, width: bounds.width, height: 13)
            labelLayer.contentsScale = UIScreen.main.scale
            labelLayer.alignmentMode = .left
            axisLayer.addSublayer(labelLayer)
        }
        axisLayer.path = path
        
        return axisLayer
    }
}
