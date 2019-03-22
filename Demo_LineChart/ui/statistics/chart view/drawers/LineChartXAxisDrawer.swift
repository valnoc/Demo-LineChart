//
//  LineChartXAxisDrawer.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 21/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartXAxisDrawer {
    fileprivate let labelDrawer = LineChartLabelDrawer()
    
    fileprivate var axisLayer: CAShapeLayer = CAShapeLayer()
    fileprivate let axisLabelOffset: CGFloat = 5
    fileprivate var prevAxisLayer: CAShapeLayer = CAShapeLayer()
    
    fileprivate var xAxisDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    //MARK: - layout
    func layoutAxis(viewLayer: CALayer,
                    chartRect: CGRect,
                    prevChartRect: CGRect,
                    affine: CGAffineTransform,
                    bottomOffset: CGFloat) {
        guard prevChartRect.maxY != chartRect.maxY || prevChartRect.minY != chartRect.minY else { return }
        
        prevAxisLayer.removeFromSuperlayer()
        prevAxisLayer = axisLayer
        
        axisLayer = makeXAxisLayer(bounds: viewLayer.bounds,
                                   chartRect: chartRect,
                                   affine: affine,
                                   bottomOffset: bottomOffset)
        viewLayer.insertSublayer(axisLayer, below: viewLayer.sublayers?.first)
        
        animateLayersChange(chartRect: chartRect,
                            prevChartRect: prevChartRect)
    }
    
    fileprivate func animateLayersChange(chartRect: CGRect,
                                         prevChartRect: CGRect) {
        setupAnimation()
        
        axisLayer.opacity = 0.0
        prevAxisLayer.opacity = 1.0
        
        var directionFraction: CGFloat = 1.0
        if prevChartRect.maxY > chartRect.maxY {
            directionFraction = 0.5
        } else {
            directionFraction = 1.5
        }
        
        var yAxisPosition = axisLayer.position
        yAxisPosition.y = yAxisPosition.y * directionFraction
        axisLayer.position = yAxisPosition
        
        yAxisPosition.y = axisLayer.frame.height / 2
        
        var prevYAxisPosition = prevAxisLayer.position
        prevYAxisPosition.y = prevYAxisPosition.y * (2 - directionFraction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) { [weak self] in
            guard let __self = self else { return }
            __self.prevAxisLayer.opacity = 0.0
            __self.prevAxisLayer.position = prevYAxisPosition
            __self.axisLayer.opacity = 1.0
            __self.axisLayer.position = yAxisPosition
        }
    }
    
    fileprivate func setupAnimation() {
        let animation = CABasicAnimation()
        animation.duration = CATransaction.animationDuration() / 2
        animation.timingFunction = CATransaction.animationTimingFunction()
        prevAxisLayer.actions = ["position": animation,
                                 "opacity": animation]
        
        let animationNew = CABasicAnimation()
        animation.duration = CATransaction.animationDuration() / 4
        animation.timingFunction = CATransaction.animationTimingFunction()
        axisLayer.actions = ["position": animationNew,
                             "opacity": animationNew]
    }
    
    // MARK: -
    fileprivate func makeXAxisLayer(bounds: CGRect,
                                    chartRect: CGRect,
                                    affine: CGAffineTransform,
                                    bottomOffset: CGFloat) -> CAShapeLayer {
        let axisLayer = makeBaseAxisLayer()
        axisLayer.frame = bounds
        
        //
        let xs = calculateXs(chartRect: chartRect, affine: affine)
        
        for x in xs {
            let date = Date(timeIntervalSince1970: Double(x))
            let label = labelDrawer.makeTextLayer(text: xAxisDateFormatter.string(from: date))
            let offset = (bottomOffset - label.frame.height) / 2
            label.origin = CGPoint(x: x, y: chartRect.minY)
                .applying(affine)
                .applying(CGAffineTransform(translationX: 0, y: -offset))
            
            axisLayer.addSublayer(label)
        }

        
        return axisLayer
        
        //
//        let axisY = bounds.height - xAxisOffset
//        let path = CGMutablePath()
//        path.addLines(between: [CGPoint(x: 0, y: axisY),
//                                CGPoint(x: bounds.width, y: axisY)])
//        axisLayer.path = path
//        //        axisLayer.addSublayer(makeAxisTextLayer(text: "\(Int(chartRect.minY))", y: axisY - yAxisLabelOffset))
//        axisLayer.addSublayer(makeAxisTextLayer(text: "\(Int(chartRect.minY))", y: axisY - 5))
        //
        
        //        let textY = bounds.height - yAxisLabelOffset
    }
    
    fileprivate func calculateXs(chartRect: CGRect,
                                 affine: CGAffineTransform) -> [CGFloat] {
        let (minX, maxX) = calculateMinMaxX(chartRect: chartRect, affine: affine)
        var xs: [CGFloat] = []
        
        var temp = maxX
        let step = (maxX - minX) / 5
        while Int(temp) > Int(minX) {
            xs.append(temp)
            temp -= step
        }
        
        return xs
    }
    
    fileprivate func calculateMinMaxX(chartRect: CGRect,
                                   affine: CGAffineTransform) -> (CGFloat, CGFloat) {
        let maxTextWidth: CGFloat = 44
        let axisRightOffset = maxTextWidth / -affine.d
        let offsetHalf = axisRightOffset / 2
        let min = chartRect.minX + offsetHalf
        let max = chartRect.maxX - offsetHalf
        return (min.rounded(),
                max.rounded())
    }
    
    fileprivate func makeBaseAxisLayer() -> CAShapeLayer {
        let axisLayer = CAShapeLayer()
        axisLayer.lineWidth = 1
        axisLayer.strokeColor = UIColor(red: 241.0 / 255.0,
                                        green: 241.0 / 255.0,
                                        blue: 241.0 / 255.0,
                                        alpha: 1).cgColor
        axisLayer.fillColor = nil
        axisLayer.masksToBounds = true
        return axisLayer
    }
}
