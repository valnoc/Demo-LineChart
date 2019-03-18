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
        
        let rect = chart.boundingRect(for: xRangePercents)
        print(rect)
        
        let affine = CGAffineTransform(scaleX: 1, y: -1)
            .scaledBy(x: bounds.width / rect.width, y: bounds.height / rect.height)
            .translatedBy(x: rect.minX, y: rect.minY)
        print(affine)
        
        for sublayer in lineLayers {
            sublayer.frame = bounds
            sublayer.setAffineTransform(affine)
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
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(hex: line.colorHex).cgColor
        layer.path = line.path
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
