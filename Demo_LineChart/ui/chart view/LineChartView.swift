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
        
        let transform = CGAffineTransform(scaleX: xScale, y: -yScale)
            .translatedBy(x: -chartRect.minX, y: -chartRect.minY - chartRect.height)
        
        for (line, sublayer) in zip(chart.lines, lineLayers) {
            sublayer.frame = bounds
            sublayer.path = line.path(applying: transform)
        }
    }
    
    // MARK: - lines
    func createAllLayers() {
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
