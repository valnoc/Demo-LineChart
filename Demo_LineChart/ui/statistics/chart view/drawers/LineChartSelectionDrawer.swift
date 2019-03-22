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
        let affinedSelectedChartX = CGPoint(x: selectedChartX, y: 0).applying(affine).x
        
        let bounds = viewLayer.bounds
        
        let selectionLayer = CALayer()
        selectionLayer.frame = bounds
        
        //---
        do {
            let backgroundPath = CGMutablePath()
            backgroundPath.addLines(between: [CGPoint(x: affinedSelectedChartX, y: 0),
                                              CGPoint(x: affinedSelectedChartX, y: bounds.height - 19)])
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
        for line in lines {
            guard let point = line.points.filter({ $0.x == CGFloat(selectedChartX) }).first else { continue }
            let affinedY = point.applying(affine).y
            
            let path = CGMutablePath()
            path.addEllipse(in: CGRect(x: affinedSelectedChartX - 9/2, y: affinedY - 9/2, width: 9, height: 9))
            
            let lineDotLayer = CAShapeLayer()
            lineDotLayer.lineWidth = 2
            lineDotLayer.fillColor = UIColor.white.cgColor
            lineDotLayer.strokeColor = UIColor(hex: line.colorHex).cgColor
            lineDotLayer.frame = bounds
            lineDotLayer.path = path
            selectionLayer.addSublayer(lineDotLayer)
        }
        
        //---
        do {
            var rect = CGRect(x: affinedSelectedChartX - 94/2, y: 0, width: 94, height: 40)
            let date = Date(timeIntervalSince1970: selectedChartX)
            
            let dayLabel = labelDrawer.makeTextLayer(text: dayFormatter.string(from: date),
                                                     font: UIFont.boldSystemFont(ofSize: 8),
                                                     fontSize: 8)
            dayLabel.origin = CGPoint(x: rect.minX + 10,
                                      y: rect.minY + 8)
            
            let yearLabel = labelDrawer.makeTextLayer(text: yearFormatter.string(from: date),
                                                      font: UIFont.boldSystemFont(ofSize: 8),
                                                      fontSize: 8)
            dayLabel.origin = CGPoint(x: dayLabel.frame.minX,
                                      y: dayLabel.frame.maxY + 8)
            
            var lineLables: [CATextLayer] = []
            for line in lines{
                guard let point = line.points.filter({ $0.x == CGFloat(selectedChartX) }).first else { continue }
                
                let label = labelDrawer.makeTextLayer(text: "\(Int(point.y))",
                                          font: UIFont.boldSystemFont(ofSize: 8),
                                          fontSize: 8,
                                          color: UIColor(hex: line.colorHex))
                label.origin = CGPoint(x: rect.maxX - 10 - label.frame.size.width,
                                          y: rect.minY + 8 + (7 + label.frame.size.height) * CGFloat(lineLables.count))
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
            
            backgroundShape.addSublayer(dayLabel)
            backgroundShape.addSublayer(yearLabel)
            lineLables.forEach({ backgroundShape.addSublayer($0) })
            
            selectionLayer.addSublayer(backgroundShape)
        }
        
        //---
        self.selectionLayer = selectionLayer
        viewLayer.addSublayer(selectionLayer)
    }
}
