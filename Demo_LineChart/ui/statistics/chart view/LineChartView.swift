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
    fileprivate let yAxisLabelOffset: CGFloat = 5
    fileprivate var prevYAxisLayer: CAShapeLayer
    
    fileprivate var prevChartRect: CGRect
    
    fileprivate var xAxisLayer: CAShapeLayer
    fileprivate var prevXAxisLayer: CAShapeLayer
    fileprivate let xAxisOffset: CGFloat = 19
    fileprivate let xAxisDateFormatter: DateFormatter
    
    fileprivate let textHeight: CGFloat = 13
    
    fileprivate var selectedChartX: Double?
    fileprivate var selectionLayer: CALayer?
    fileprivate var selectionDateFormatter1: DateFormatter
    fileprivate var selectionDateFormatter2: DateFormatter
    
    init(chart: LineChart,
         showAxes: Bool = true) {
        self.chart = chart
        self.showAxes = showAxes
        
        yAxisLayer = CAShapeLayer()
        prevYAxisLayer = CAShapeLayer()
        
        prevChartRect = CGRect.zero
        
        xAxisLayer = CAShapeLayer()
        prevXAxisLayer = CAShapeLayer()
        xAxisDateFormatter = DateFormatter()
        selectionDateFormatter1 = DateFormatter()
        selectionDateFormatter2 = DateFormatter()
        super.init(frame: .zero)
        
        for i in 0..<chart.lines.count {
            linesIndexToEnabled[i] = true
        }
        
        backgroundColor = .white
        
        xAxisDateFormatter.dateFormat = "MMM dd"
        selectionDateFormatter1.dateFormat = "MMM dd"
        selectionDateFormatter2.dateFormat = "YYYY"
        
        layer.masksToBounds = true
        setupLineLayers()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - api
    func show(xRangePercents: ClosedRange<CGFloat>) {
        guard xRangePercents.lowerBound >= 0.0,
            xRangePercents.upperBound <= 1.0 else { return }
        self.xRangePercents = xRangePercents
        self.selectedChartX = nil
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
        
        let chartRect = makeChartRect()
        defer {
            prevChartRect = chartRect
        }
        
        let xScale = bounds.width / chartRect.width
        let yScale = (bounds.height - (showAxes ? xAxisOffset : 0)) / chartRect.height
        
        let affine = CGAffineTransform(scaleX: xScale, y: -yScale)
            .translatedBy(x: -chartRect.minX, y: -chartRect.minY - chartRect.height)
        
        for (index, (line, sublayer)) in zip(chart.lines, lineLayers).enumerated() {
            sublayer.frame = bounds
            sublayer.path = line.path(applying: affine)
            sublayer.opacity = linesIndexToEnabled[index] == true ? 1: 0
        }
        
        drawSelectionLayer(chartRect: chartRect, affine: affine)
        
        guard showAxes else { return }
        animateYAxis(chartRect: chartRect, affine: affine)
        animateXAxis(chartRect: chartRect, affine: affine)
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

    // MARK: - y axis
    func makeYAxisLayer(chartRect: CGRect, affine: CGAffineTransform) -> CAShapeLayer {
        let axisLayer = makeBaseAxisLayer()

        //
        let axisMaxYTopOffset = (textHeight + yAxisLabelOffset * 2) * chartRect.height / bounds.height
        
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
            while Int(axisYTemp) > Int(chartRect.minY) {
                axisYs.append(axisYTemp)
                axisYTemp -= axisYStep
            }
        }
        
        let path = CGMutablePath()
        for y in axisYs {
            let affinedY = CGPoint(x: 0, y: y).applying(affine).y
            path.addLines(between: [
                CGPoint(x: 0, y: affinedY),
                CGPoint(x: bounds.width, y: affinedY)
                ])
            axisLayer.addSublayer(makeAxisTextLayer(text: "\(Int(y))", y: affinedY - yAxisLabelOffset))
        }
        axisLayer.path = path
        
        return axisLayer
    }
    
    func animateYAxis(chartRect: CGRect, affine: CGAffineTransform) {
        guard prevChartRect.maxY != chartRect.maxY || prevChartRect.minY != chartRect.minY else { return }
        var directionFraction: CGFloat = 1.0
        if prevChartRect.maxY > chartRect.maxY {
            directionFraction = 1.5
        } else {
            directionFraction = 0.5
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
    
    // MARK: - x axis
    func makeXAxisLayer(chartRect: CGRect, affine: CGAffineTransform) -> CAShapeLayer {
        let axisLayer = makeBaseAxisLayer()
        
        //
        let axisY = bounds.height - xAxisOffset
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: axisY),
                                CGPoint(x: bounds.width, y: axisY)])
        axisLayer.path = path
        axisLayer.addSublayer(makeAxisTextLayer(text: "\(Int(chartRect.minY))", y: axisY - yAxisLabelOffset))

        //
        let labelWidth: CGFloat = 42
        let axisXSideOffset = labelWidth * chartRect.width / bounds.width

        var axisXs: [CGFloat] = []

        let axisMaxX = chartRect.maxX - axisXSideOffset
        let axisMinX = chartRect.minX + axisXSideOffset

        do {
            var axisXTemp = axisMaxX
            let axisXStep = (axisMaxX - axisMinX) / 5
            while Int(axisXTemp) > Int(axisMinX) {
                axisXs.append(axisXTemp)
                axisXTemp -= axisXStep
            }
            axisXs.append(axisMinX)
        }

        let textY = bounds.height - yAxisLabelOffset
        for x in axisXs {
            let affinedX = CGPoint(x: x, y: 0).applying(affine).x - labelWidth / 2
            let date = Date(timeIntervalSince1970: Double(x))
            let label = makeAxisTextLayer(text: xAxisDateFormatter.string(from: date),
                                         x: affinedX,
                                         y: textY)
            var frame = label.frame
            frame.size.width = labelWidth
            label.frame = frame
            axisLayer.addSublayer(label)
        }
        
        return axisLayer
    }
    
    func animateXAxis(chartRect: CGRect, affine: CGAffineTransform) {
        guard prevChartRect.maxX != chartRect.maxX || prevChartRect.minX != chartRect.minX else { return }
        
        var directionFraction: CGFloat = 1.0
        if prevChartRect.maxX > chartRect.maxX {
            directionFraction = 0.5
        } else {
            directionFraction = 1.5
        }

        prevXAxisLayer.removeFromSuperlayer()
        prevXAxisLayer = xAxisLayer
        xAxisLayer = makeXAxisLayer(chartRect: chartRect, affine: affine)

        xAxisLayer.opacity = 0.0
        var xAxisPosition = xAxisLayer.position
        xAxisPosition.x = xAxisPosition.x * directionFraction
        xAxisLayer.position = xAxisPosition
        xAxisPosition.x = xAxisLayer.frame.height / 2

        var prevXAxisPosition = prevXAxisLayer.position
        prevXAxisPosition.x = prevXAxisPosition.x * (2 - directionFraction)

        let animation = CABasicAnimation()
        animation.duration = CATransaction.animationDuration() / 2
        animation.timingFunction = CATransaction.animationTimingFunction()
        prevXAxisLayer.actions = ["position": animation,
                                  "opacity": animation]

        let animationNew = CABasicAnimation()
        animation.duration = CATransaction.animationDuration() / 4
        animation.timingFunction = CATransaction.animationTimingFunction()
        xAxisLayer.actions = ["position": animationNew,
                              "opacity": animationNew]

        layer.insertSublayer(xAxisLayer, below: lineLayers.first)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) { [weak self] in
            guard let __self = self else { return }
            __self.prevXAxisLayer.opacity = 0.0
            __self.prevXAxisLayer.position = prevXAxisPosition
            __self.xAxisLayer.opacity = 1.0
            __self.xAxisLayer.position = xAxisPosition
        }
    }
    
    // MARK: - axis
    func makeAxisTextLayer(text: String, x: CGFloat = 0, y: CGFloat = 0) -> CATextLayer {
        let labelLayer = CATextLayer()
        labelLayer.fontSize = textHeight
        labelLayer.string = text
        labelLayer.foregroundColor = UIColor(red: 144.0 / 255.0,
                                             green: 150 / 255.0,
                                             blue: 156 / 255.0,
                                             alpha: 1).cgColor
        labelLayer.frame = CGRect(x: x, y: y - textHeight, width: bounds.width, height: 21)
        labelLayer.contentsScale = UIScreen.main.scale
        labelLayer.alignmentMode = .left
        return labelLayer
    }
    
    func makeBaseAxisLayer() -> CAShapeLayer {
        let axisLayer = CAShapeLayer()
        axisLayer.lineWidth = 1
        axisLayer.strokeColor = UIColor(red: 241.0 / 255.0,
                                        green: 241.0 / 255.0,
                                        blue: 241.0 / 255.0,
                                        alpha: 1).cgColor
        axisLayer.fillColor = nil
        axisLayer.masksToBounds = true
        axisLayer.frame = bounds
        return axisLayer
    }
    
    // MARK: - tap
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let chartRect = makeChartRect()
            
            let xScale = bounds.width / chartRect.width

            let point = sender.location(in: self)
            let chartPointX = point.x / xScale + chartRect.minX
            
            guard let line = chart.lines.first else { return }
           
            let leftChartX = line.x.filter({ $0 <= Double(chartPointX) }).first
            let rightChartX = line.x.filter({ $0 >= Double(chartPointX) }).first
 
            var chartX: Double = -1
            if let leftChartX = leftChartX,
                let rightChartX = rightChartX {
                let leftDistance = abs(Double(chartPointX) - leftChartX)
                let rightDistance = abs(Double(chartPointX) - rightChartX)
                if leftDistance < rightDistance {
                    chartX = leftChartX
                } else {
                    chartX = rightChartX
                }
            } else if let leftChartX = leftChartX {
                chartX = leftChartX
                
            } else if let rightChartX = rightChartX {
                chartX = rightChartX
            }
            
            selectedChartX = chartX
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func drawSelectionLayer(chartRect: CGRect, affine: CGAffineTransform) {
        self.selectionLayer?.removeFromSuperlayer()
        guard let selectedChartX = selectedChartX else { return }
        let affinedSelectedChartX = CGPoint(x: selectedChartX, y: 0).applying(affine).x
        
        let selectionLayer = CALayer()
        selectionLayer.frame = bounds
        
        //---
        do {
            let backgroundPath = CGMutablePath()
            backgroundPath.addLines(between: [CGPoint(x: affinedSelectedChartX, y: 0),
                                              CGPoint(x: affinedSelectedChartX, y: bounds.height - xAxisOffset)])
            let backgrShape = CAShapeLayer()
            backgrShape.frame = bounds
            backgrShape.path = backgroundPath
            backgrShape.strokeColor = UIColor(red: 244.0 / 255.0,
                                              green: 243.0 / 255.0,
                                              blue: 249.0 / 255.0,
                                              alpha: 1).cgColor
            backgrShape.fillColor = backgrShape.strokeColor
            backgrShape.lineWidth = 1
            selectionLayer.addSublayer(backgrShape)
        }
        
        //---
        let enabledLinesIndexes = makeEnabledLinesIndexes()
        for (index, line) in chart.lines.enumerated() {
            guard enabledLinesIndexes.contains(index) else { continue }
            guard let point = line.points.filter({ $0.x == CGFloat(selectedChartX) }).first else { continue }
            let affinedY = point.applying(affine).y
            
            let path = CGMutablePath()
            path.addEllipse(in: CGRect(x: affinedSelectedChartX - 9/2, y: affinedY - 9/2, width: 9, height: 9))
            
            let lineDotLayer = makeLayer(for: line)
            lineDotLayer.frame = bounds
            lineDotLayer.path = path
            lineDotLayer.fillColor = UIColor.white.cgColor
            selectionLayer.addSublayer(lineDotLayer)
        }
        
        //---
        do {
            var rect = CGRect(x: affinedSelectedChartX - 94/2, y: 0, width: 94, height: 40)
            let date = Date(timeIntervalSince1970: selectedChartX)
            
            let date1Label = makeAxisTextLayer(text: selectionDateFormatter1.string(from: date))
            date1Label.font = UIFont.boldSystemFont(ofSize: 8)
            date1Label.fontSize = 8
            var frame = date1Label.frame
            frame.origin.x = rect.minX + 10
            frame.origin.y = rect.minY + 8
            frame.size = date1Label.preferredFrameSize()
            date1Label.frame = frame
            
            let date2Label = makeAxisTextLayer(text: selectionDateFormatter2.string(from: date))
            date2Label.fontSize = 8
            frame = date2Label.frame
            frame.origin.x = date1Label.frame.minX
            frame.origin.y = date1Label.frame.maxY + 7
            date2Label.frame = frame

            var lineLables: [CATextLayer] = []
            for (index, line) in chart.lines.enumerated() {
                guard enabledLinesIndexes.contains(index) else { continue }
                guard let point = line.points.filter({ $0.x == CGFloat(selectedChartX) }).first else { continue }
                
                let label = makeAxisTextLayer(text: "\(Int(point.y))")
                label.font = UIFont.boldSystemFont(ofSize: 8)
                label.fontSize = 8
                label.foregroundColor = UIColor(hex: line.colorHex).cgColor
                
                var frame = label.frame
                frame.size = label.preferredFrameSize()
                frame.origin.y = rect.minY + 8 + (7 + frame.size.height) * CGFloat(lineLables.count)
                frame.origin.x = rect.maxX - 10 - frame.size.width
                label.frame = frame
                
                lineLables.append(label)
            }
            
            if lineLables.count > 2 {
                rect.size.height = lineLables.last!.frame.maxY + 8
            }
            
            let backgroundPath = CGMutablePath()
            backgroundPath.addRoundedRect(in: rect,
                                          cornerWidth: 1,
                                          cornerHeight: 1)
            let backgroundShape = CAShapeLayer()
            backgroundShape.frame = bounds
            backgroundShape.path = backgroundPath
            backgroundShape.strokeColor = UIColor(red: 244.0 / 255.0,
                                              green: 243.0 / 255.0,
                                              blue: 249.0 / 255.0,
                                              alpha: 1).cgColor
            backgroundShape.fillColor = backgroundShape.strokeColor
            backgroundShape.lineWidth = 1
            
            backgroundShape.addSublayer(date1Label)
            backgroundShape.addSublayer(date2Label)
            lineLables.forEach({ backgroundShape.addSublayer($0) })
            
            selectionLayer.addSublayer(backgroundShape)
        }
        
        //---
        self.selectionLayer = selectionLayer
        layer.addSublayer(selectionLayer)
    }
    
    //MARK: - private
    func makeChartRect() -> CGRect {
        return chart.boundingRect(for: xRangePercents,
                                  includingLinesAt: makeEnabledLinesIndexes())
    }
    
    func makeEnabledLinesIndexes() -> [Int] {
        return linesIndexToEnabled
            .filter({$0.value == true})
            .map({$0.key})
    }
}
