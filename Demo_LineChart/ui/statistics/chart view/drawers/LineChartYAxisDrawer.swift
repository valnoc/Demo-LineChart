//
//  LineChartYAxisDrawer.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 21/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartYAxisDrawer {
    fileprivate let labelDrawer = LineChartLabelDrawer()
    
    fileprivate var yAxisLayer: CAShapeLayer = CAShapeLayer()
    fileprivate let yAxisLabelOffset: CGFloat = 5
    fileprivate var prevYAxisLayer: CAShapeLayer = CAShapeLayer()
    
    //MARK: - layout
    func layoutAxis(chart: LineChart,
                    viewLayer: CALayer,
                    chartRect: CGRect,
                    prevChartRect: CGRect,
                    affine: CGAffineTransform) {
        guard prevChartRect.maxY != chartRect.maxY || prevChartRect.minY != chartRect.minY else { return }
        
        prevYAxisLayer.removeFromSuperlayer()
        prevYAxisLayer = yAxisLayer
        
        yAxisLayer = makeYAxisLayer(bounds: viewLayer.bounds,
                                    chartRect: chartRect,
                                    affine: affine)
        viewLayer.insertSublayer(yAxisLayer, below: viewLayer.sublayers?.first)
        
        animateLayersChange(chartRect: chartRect,
                            prevChartRect: prevChartRect)
    }
    
    fileprivate func animateLayersChange(chartRect: CGRect,
                                         prevChartRect: CGRect) {
        setupAnimation()
        
        yAxisLayer.opacity = 0.0
        prevYAxisLayer.opacity = 1.0
        
        var directionFraction: CGFloat = 1.0
        if prevChartRect.maxY > chartRect.maxY {
            directionFraction = 1.5
        } else {
            directionFraction = 0.5
        }
        
        var yAxisPosition = yAxisLayer.position
        yAxisPosition.y = yAxisPosition.y * directionFraction
        yAxisLayer.position = yAxisPosition
        
        yAxisPosition.y = yAxisLayer.frame.height / 2
        
        var prevYAxisPosition = prevYAxisLayer.position
        prevYAxisPosition.y = prevYAxisPosition.y * (2 - directionFraction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) { [weak self] in
            guard let __self = self else { return }
            __self.prevYAxisLayer.opacity = 0.0
            __self.prevYAxisLayer.position = prevYAxisPosition
            __self.yAxisLayer.opacity = 1.0
            __self.yAxisLayer.position = yAxisPosition
        }
    }
    
    fileprivate func setupAnimation() {
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
    }
    
    // MARK: -
    fileprivate func makeYAxisLayer(bounds: CGRect,
                                    chartRect: CGRect,
                                    affine: CGAffineTransform) -> CAShapeLayer {
        let axisLayer = makeBaseAxisLayer()
        axisLayer.frame = bounds
        
        //
        var ys: [CGFloat] = []
        let maxY = calculateMaxY(chartRect: chartRect, affine: affine)
        
        do {
            var axisYTemp = maxY
            let axisYStep = (maxY - chartRect.minY) / 5
            while Int(axisYTemp) > Int(chartRect.minY) {
                ys.append(axisYTemp)
                axisYTemp -= axisYStep
            }
        }
        
        let path = CGMutablePath()
        for y in ys {
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
    
    fileprivate func calculateMaxY(chartRect: CGRect,
                                   affine: CGAffineTransform) -> CGFloat {
        let textHeight: CGFloat = 13
        let axisTopOffset = CGPoint(x: 0,
                                    y: (textHeight + yAxisLabelOffset * 2))
            .applying(affine)
            .y
        
        var maxY = chartRect.maxY - axisTopOffset + 1
        var maxYLastDigit: CGFloat = 0
        
        repeat {
            maxY -= 1
            maxYLastDigit = maxY
                .rounded()
                .truncatingRemainder(dividingBy: 10)
        } while maxYLastDigit != 5 && maxYLastDigit != 0
        
        return maxY
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
