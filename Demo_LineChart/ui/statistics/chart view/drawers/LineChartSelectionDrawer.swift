//
//  LineChartSelectionDrawer.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 22/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartSelectionDrawer {
    fileprivate let labelDrawer = LineChartLabelDrawer()
    
    fileprivate var selectedChartX: Double?
    fileprivate var selectionLayer: CALayer?
    
    fileprivate var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    fileprivate var yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter
    }()
   
    func handleTapAt(pointX: CGFloat,
                     lines: [LineChart.Line]) {
        guard let line = lines.first else {
            selectedChartX = nil
            return
        }
        
        let leftChartX = line.x.filter({ $0 <= Double(pointX) }).first
        let rightChartX = line.x.filter({ $0 >= Double(pointX) }).first
        
        var chartX: Double = -1
        if let leftChartX = leftChartX,
            let rightChartX = rightChartX {
            let leftDistance = abs(Double(pointX) - leftChartX)
            let rightDistance = abs(Double(pointX) - rightChartX)
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
    }
    
    //MARK: - layout
    func layoutSelection(lines: [LineChart.Line],
                     viewLayer: CALayer,
                     chartRect: CGRect,
                     affine: CGAffineTransform) {
        self.selectionLayer?.removeFromSuperlayer()
        guard let selectedChartX = selectedChartX else { return }
        
        let bounds = viewLayer.bounds
        
        let selectionLayer = CALayer()
        selectionLayer.frame = bounds
        
        drawVerticalLine(selectionLayer: selectionLayer,
                         x: selectedChartX,
                         chartRect: chartRect,
                         affine: affine)
        
        drawLinesDots(selectionLayer: selectionLayer,
                      x: selectedChartX,
                      lines: lines,
                      chartRect: chartRect,
                      affine: affine)

        drawInfo(selectionLayer: selectionLayer,
                 x: selectedChartX,
                 lines: lines,
                 chartRect: chartRect,
                 affine: affine)

        self.selectionLayer = selectionLayer
        viewLayer.addSublayer(selectionLayer)
    }
    
    fileprivate func drawVerticalLine(selectionLayer: CALayer,
                                      x: Double,
                                      chartRect: CGRect,
                                      affine: CGAffineTransform) {
        let points = [CGPoint(x: CGFloat(x), y: chartRect.minY),
                      CGPoint(x: CGFloat(x), y: chartRect.maxY)]
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: affine)
        
        let layer = CAShapeLayer()
        layer.frame = selectionLayer.bounds
        layer.path = path
        layer.strokeColor = UIColor(red: 244.0 / 255.0,
                                    green: 243.0 / 255.0,
                                    blue: 249.0 / 255.0,
                                    alpha: 1).cgColor
        layer.fillColor = layer.strokeColor
        layer.lineWidth = 1
        selectionLayer.addSublayer(layer)
    }
    
    fileprivate func drawLinesDots(selectionLayer: CALayer,
                                      x: Double,
                                      lines: [LineChart.Line],
                                      chartRect: CGRect,
                                      affine: CGAffineTransform) {
        for line in lines {
            guard let point = line.points.filter({ $0.x == CGFloat(x) }).first else { continue }
            
            let affinedPoint = point.applying(affine)
            let rect = CGRect(x: affinedPoint.x - 9/2,
                              y: affinedPoint.y - 9/2,
                              width: 9,
                              height: 9)
            
            let path = CGMutablePath()
            path.addEllipse(in: rect)
            
            let lineDotLayer = CAShapeLayer()
            lineDotLayer.lineWidth = 2
            lineDotLayer.fillColor = UIColor.white.cgColor
            lineDotLayer.strokeColor = UIColor(hex: line.colorHex).cgColor
            lineDotLayer.frame = selectionLayer.bounds
            lineDotLayer.path = path
            
            selectionLayer.addSublayer(lineDotLayer)
        }
    }
    
    fileprivate func drawInfo(selectionLayer: CALayer,
                                   x: Double,
                                   lines: [LineChart.Line],
                                   chartRect: CGRect,
                                   affine: CGAffineTransform) {
        let date = Date(timeIntervalSince1970: x)
        
        //
        let dayLabel = labelDrawer.makeTextLayer(text: dayFormatter.string(from: date),
                                                 font: UIFont.boldSystemFont(ofSize: 8),
                                                 fontSize: 8)
        
        //
        let yearLabel = labelDrawer.makeTextLayer(text: yearFormatter.string(from: date),
                                                  fontSize: 8)
        
        //
        var lineLables: [CATextLayer] = []
        for line in lines{
            guard let point = line.points.filter({ $0.x == CGFloat(x) }).first else { continue }
            
            let label = labelDrawer.makeTextLayer(text: "\(Int(point.y))",
                font: UIFont.boldSystemFont(ofSize: 8),
                fontSize: 8,
                color: UIColor(hex: line.colorHex))
            lineLables.append(label)
        }
        
        var rect = CGRect.zero
        if !lineLables.isEmpty {
            let vertInset: CGFloat = 8
            let horInset: CGFloat = 10
            
            let height = max(
                vertInset + dayLabel.bounds.height + vertInset + yearLabel.bounds.height + vertInset,
                vertInset + lineLables.reduce(0, { $0 + $1.bounds.height + vertInset })
                )
            
            var widthsArray: [CGFloat] = []
            for (index, label) in lineLables.enumerated() {
                var value = horInset + label.bounds.width + horInset
                if index == 0 { value += 20 + dayLabel.bounds.size.width }
                if index == 1 { value += 20 + yearLabel.bounds.size.width }
                widthsArray.append(value)
            }
            let width = widthsArray.max() ?? 0
            
            let size = CGSize(width: width, height: height)
            var origin = CGPoint(x: CGFloat(x), y: chartRect.maxY)
                .applying(affine)
                .applying(CGAffineTransform(translationX: -size.width / 2, y: 0))
            
            let minX: CGFloat = 0
            let maxX: CGFloat = selectionLayer.bounds.width - size.width
            if origin.x < minX { origin.x = minX }
            if origin.x > maxX { origin.x = maxX }
            
            rect = CGRect(origin: origin, size: size)
            
            dayLabel.origin = CGPoint(x: rect.minX + horInset, y: rect.minY + vertInset)
            yearLabel.origin = CGPoint(x: dayLabel.frame.minX, y: dayLabel.frame.maxY + vertInset)
            
            var lastMaxY = vertInset
            for label in lineLables {
                label.origin = CGPoint(x: rect.maxX - horInset - label.frame.width,
                                       y: lastMaxY)
                lastMaxY += vertInset + label.frame.height
            }
        }
        
        //
        let backgroundPath = CGMutablePath()
        backgroundPath.addRoundedRect(in: rect,
                                      cornerWidth: 1,
                                      cornerHeight: 1)
        let backgroundShape = CAShapeLayer()
        backgroundShape.frame = selectionLayer.bounds
        backgroundShape.path = backgroundPath
        backgroundShape.strokeColor = UIColor(red: 244.0 / 255.0,
                                              green: 243.0 / 255.0,
                                              blue: 249.0 / 255.0,
                                              alpha: 1).cgColor
        backgroundShape.fillColor = backgroundShape.strokeColor
        backgroundShape.lineWidth = 1
        
        //
        backgroundShape.addSublayer(dayLabel)
        backgroundShape.addSublayer(yearLabel)
        lineLables.forEach({ backgroundShape.addSublayer($0) })
        
        //
        selectionLayer.addSublayer(backgroundShape)
    }
}
