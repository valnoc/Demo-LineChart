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
    
    fileprivate var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    //MARK: - layout
    func layoutAxis(viewLayer: CALayer,
                    chartRect: CGRect,
                    prevChartRect: CGRect,
                    affine: CGAffineTransform) {
        guard prevChartRect.maxX != chartRect.maxX || prevChartRect.minX != chartRect.minX else { return }
        
        prevAxisLayer.removeFromSuperlayer()
        prevAxisLayer = axisLayer
        
        axisLayer = makeXAxisLayer(bounds: viewLayer.bounds,
                                   chartRect: chartRect,
                                   affine: affine)
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
        if prevChartRect.maxX > chartRect.maxX {
            directionFraction = 0.5
        } else {
            directionFraction = 1.5
        }
        
        var axisPosition = axisLayer.position
        axisPosition.x = axisPosition.x * directionFraction
        axisLayer.position = axisPosition
        
        axisPosition.x = axisLayer.frame.width / 2
        
        var prevAxisPosition = prevAxisLayer.position
        prevAxisPosition.x = prevAxisPosition.x * (2 - directionFraction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) { [weak self] in
            guard let __self = self else { return }
            __self.prevAxisLayer.opacity = 0.0
            __self.prevAxisLayer.position = prevAxisPosition
            __self.axisLayer.opacity = 1.0
            __self.axisLayer.position = axisPosition
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
                                    affine: CGAffineTransform) -> CAShapeLayer {
        let axisLayer = makeBaseAxisLayer()
        axisLayer.frame = bounds
        
        drawXAxisWithYMin(axisLayer: axisLayer,
                          chartRect: chartRect,
                          affine: affine)
        //
        let xs = calculateXs(chartRect: chartRect, affine: affine)
        
        for x in xs {
            let date = Date(timeIntervalSince1970: Double(x))
            let label = labelDrawer.makeTextLayer(text: dateFormatter.string(from: date), fontSize: 8)
            label.origin = CGPoint(x: x, y: chartRect.minY)
                .applying(affine)
            label.origin = label.origin
                .applying(CGAffineTransform(translationX: -label.bounds.width / 2,
                                            y: (bounds.height - label.frame.maxY) / 2))
            
            axisLayer.addSublayer(label)
        }

        
        return axisLayer
    }
    
    fileprivate func drawXAxisWithYMin(axisLayer: CAShapeLayer,
                                       chartRect: CGRect,
                                       affine: CGAffineTransform) {
        let points = [CGPoint(x: chartRect.minX, y: chartRect.minY),
                      CGPoint(x: chartRect.maxX, y: chartRect.minY)]

        let path = CGMutablePath()
        path.addLines(between: points,
                      transform: affine)
        axisLayer.path = path
        
        //
        let label = labelDrawer.makeTextLayer(text: "\(Int(chartRect.minY))", fontSize: 8)
        label.origin = CGPoint(x: chartRect.minX, y: chartRect.minY)
            .applying(affine)
            .applying(CGAffineTransform(translationX: 0, y: -axisLabelOffset - label.bounds.height))
        axisLayer.addSublayer(label)
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
        xs.append(minX)
        
        return xs
    }
    
    fileprivate func calculateMinMaxX(chartRect: CGRect,
                                   affine: CGAffineTransform) -> (CGFloat, CGFloat) {
        let maxTextWidth: CGFloat = 44
        let axisRightOffset = maxTextWidth / affine.a
        let min = chartRect.minX + axisRightOffset / 2
        let max = chartRect.maxX - axisRightOffset / 2
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
