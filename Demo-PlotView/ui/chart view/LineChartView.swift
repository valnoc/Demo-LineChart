//
//  ChartView.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartView: UIView {
    let chart: LineChart
    
    var lineLayers: [CAShapeLayer] = []
    
    var xRangePercents: ClosedRange<CGFloat> = 0.0...1.0
    
    init(chart: LineChart) {
        self.chart = chart
        super.init(frame: .zero)
        
        backgroundColor = .white
        createAllLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - size
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let chartRect = chart.boundingRect(for: xRangePercents)
        
        let xScale = bounds.width / chartRect.width
        let yScale = bounds.height / chartRect.height
        
        let affine = CGAffineTransform(scaleX: xScale, y: -yScale)
            .translatedBy(x: -chartRect.minX, y: -chartRect.height)
        
        for (index, sublayer) in lineLayers.enumerated() {
            sublayer.frame = bounds
            
            let linePoints = chart.lines[index].points
            let path = CGMutablePath()
            path.addLines(between: linePoints, transform: affine)
            sublayer.path = path
        }
    }
    
    // MARK: - lines
    func createAllLayers() {
        guard let line = chart.lines.first else { return }
        
        let lineLayer = makeLayer(for: line)
        layer.addSublayer(lineLayer)
        lineLayers.append(lineLayer)
    }
    
    func makeLayer(for line: LineChart.Line) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineWidth = 5
        layer.fillColor = nil
        layer.strokeColor = UIColor(hex: line.colorHex).cgColor
        layer.path = line.path
        layer.lineJoin = .round
        return layer
    }

    // MARK: - scaling the x range
    func show(xRangePercents: ClosedRange<CGFloat>) {
        guard xRangePercents.lowerBound >= 0.0,
            xRangePercents.upperBound <= 1.0 else { return }
        self.xRangePercents = xRangePercents
        setNeedsLayout()
        layoutIfNeeded()
    }
}
