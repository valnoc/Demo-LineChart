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
    fileprivate var xRangePercents: ClosedRange<CGFloat> = 0.0...1.0
    fileprivate let showAxes: Bool
    
    fileprivate var prevChartRect: CGRect
    
    fileprivate let xAxisBottomOffset: CGFloat = 19
    
    fileprivate let textHeight: CGFloat = 13
    
    fileprivate var selectedChartX: Double?
    fileprivate var selectionLayer: CALayer?
    fileprivate var selectionDateFormatter1: DateFormatter
    fileprivate var selectionDateFormatter2: DateFormatter
    
    fileprivate var linesDrawer: LineChartLinesDrawer
    fileprivate var yAxisDrawer: LineChartYAxisDrawer
    fileprivate var xAxisDrawer: LineChartXAxisDrawer
    
    init(chart: LineChart,
         showAxes: Bool = true) {
        self.chart = chart
        self.showAxes = showAxes
        
        linesDrawer = LineChartLinesDrawer()
        yAxisDrawer = LineChartYAxisDrawer()
        xAxisDrawer = LineChartXAxisDrawer()
        
        prevChartRect = CGRect.zero
        
        selectionDateFormatter1 = DateFormatter()
        selectionDateFormatter2 = DateFormatter()
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        selectionDateFormatter1.dateFormat = "MMM dd"
        selectionDateFormatter2.dateFormat = "YYYY"
        
        layer.masksToBounds = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        
        linesDrawer.setupLineLayers(chart: chart, viewLayer: layer)
        setNeedsLayout()
        layoutIfNeeded()
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
        linesDrawer.toggleLine(at: index)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func isLineEnabled(at index: Int) -> Bool {
        return linesDrawer.isLineEnabled(at: index)
    }
    
    // MARK: - size
    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.size != .zero else { return }
        
        let chartRect = makeChartRect()
        defer {
            prevChartRect = chartRect
        }
        
        let xScale = bounds.width / chartRect.width
        let yScale = (bounds.height - (showAxes ? xAxisBottomOffset : 0)) / chartRect.height
        
        let affine = CGAffineTransform(scaleX: xScale, y: -yScale)
            .translatedBy(x: -chartRect.minX, y: -chartRect.minY - chartRect.height)
        
        if showAxes {
            yAxisDrawer.layoutAxis(viewLayer: layer,
                                   chartRect: chartRect,
                                   prevChartRect: prevChartRect,
                                   affine: affine)
            xAxisDrawer.layoutAxis(viewLayer: layer,
                                   chartRect: chartRect,
                                   prevChartRect: prevChartRect,
                                   affine: affine)
        }
        
        linesDrawer.layoutLines(chart: chart,
                                  viewLayer: layer,
                                  chartRect: chartRect,
                                  affine: affine)
        
        drawSelectionLayer(chartRect: chartRect, affine: affine)
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
                                              CGPoint(x: affinedSelectedChartX, y: bounds.height - xAxisBottomOffset)])
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
        for line in linesDrawer.enabledLines(chart.lines) {
            guard let point = line.points.filter({ $0.x == CGFloat(selectedChartX) }).first else { continue }
            let affinedY = point.applying(affine).y
            
            let path = CGMutablePath()
            path.addEllipse(in: CGRect(x: affinedSelectedChartX - 9/2, y: affinedY - 9/2, width: 9, height: 9))
            
            let lineDotLayer = linesDrawer.makeLayer(for: line)
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
            for line in linesDrawer.enabledLines(chart.lines) {
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
                                  includingLinesAt: linesDrawer.enabledLinesIndexes())
    }
}
