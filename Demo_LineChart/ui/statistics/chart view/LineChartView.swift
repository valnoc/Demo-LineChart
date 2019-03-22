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
    
    fileprivate var linesDrawer: LineChartLinesDrawer
    fileprivate var yAxisDrawer: LineChartYAxisDrawer
    fileprivate var xAxisDrawer: LineChartXAxisDrawer
    fileprivate var selectionDrawer: LineChartSelectionDrawer
    
    init(chart: LineChart,
         showAxes: Bool = true) {
        self.chart = chart
        self.showAxes = showAxes
        
        linesDrawer = LineChartLinesDrawer()
        yAxisDrawer = LineChartYAxisDrawer()
        xAxisDrawer = LineChartXAxisDrawer()
        selectionDrawer = LineChartSelectionDrawer()
        
        prevChartRect = CGRect.zero

        super.init(frame: .zero)
        
        backgroundColor = .white
        
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
        self.selectionDrawer.handleTapAt(pointX: -1, lines: [])
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
            .translatedBy(x: -chartRect.minX,
                          y: -chartRect.minY - chartRect.height)
        
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
        selectionDrawer.layoutSelection(lines: linesDrawer.enabledLines(chart.lines),
                                        viewLayer: layer,
                                        chartRect: chartRect,
                                        affine: affine)
    }
 
    // MARK: - tap
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let chartRect = makeChartRect()
            
            let (xScale, _) = makeXYScale()
            let point = sender.location(in: self)
            let chartPointX = point.x / xScale + chartRect.minX
            
            selectionDrawer.handleTapAt(pointX: chartPointX,
                                        lines: linesDrawer.enabledLines(chart.lines))
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    //MARK: - private
    func makeChartRect() -> CGRect {
        return chart.boundingRect(for: xRangePercents,
                                  includingLinesAt: linesDrawer.enabledLinesIndexes())
    }
    
    func makeXYScale() -> (CGFloat, CGFloat) {
        return (1, 1)
    }
}
