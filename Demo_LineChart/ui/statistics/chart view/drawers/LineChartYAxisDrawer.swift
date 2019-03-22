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
    
    fileprivate var axisLayer: CAShapeLayer = CAShapeLayer()
    fileprivate let axisLabelOffset: CGFloat = 5
    fileprivate var prevAxisLayer: CAShapeLayer = CAShapeLayer()
    
    //MARK: - layout
    func layoutAxis(viewLayer: CALayer,
                    chartRect: CGRect,
                    prevChartRect: CGRect,
                    affine: CGAffineTransform) {
        guard prevChartRect.maxY != chartRect.maxY || prevChartRect.minY != chartRect.minY else { return }
        
        prevAxisLayer.removeFromSuperlayer()
        prevAxisLayer = axisLayer
        
        axisLayer = makeYAxisLayer(bounds: viewLayer.bounds,
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
        if prevChartRect.maxY > chartRect.maxY {
            directionFraction = 1.5
        } else {
            directionFraction = 0.5
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
    fileprivate func makeYAxisLayer(bounds: CGRect,
                                    chartRect: CGRect,
                                    affine: CGAffineTransform) -> CAShapeLayer {
        let axisLayer = makeBaseAxisLayer()
        axisLayer.frame = bounds
        
        //
        let ys = calculateYs(chartRect: chartRect, affine: affine)
        
        let path = CGMutablePath()
        for y in ys {
            let points = [
                CGPoint(x: chartRect.minX, y: y),
                CGPoint(x: chartRect.maxX, y: y)
            ]
            path.addLines(between: points,
                          transform: affine)
            
            let label = labelDrawer.makeTextLayer(text: "\(Int(y))")
            label.origin = CGPoint(x: chartRect.minX, y: y)
                .applying(affine)
                .applying(CGAffineTransform(translationX: 0, y: -axisLabelOffset - label.bounds.height))
            
            axisLayer.addSublayer(label)
        }
        axisLayer.path = path
        
        return axisLayer
    }
    
    fileprivate func calculateYs(chartRect: CGRect,
                                 affine: CGAffineTransform) -> [CGFloat] {
        let maxY = calculateMaxY(chartRect: chartRect, affine: affine)
        var ys: [CGFloat] = []
        
        var axisYTemp = maxY
        let axisYStep = (maxY - chartRect.minY) / 5
        while Int(axisYTemp) > Int(chartRect.minY) {
            ys.append(axisYTemp)
            axisYTemp -= axisYStep
        }
        
        return ys
    }
    
    fileprivate func calculateMaxY(chartRect: CGRect,
                                   affine: CGAffineTransform) -> CGFloat {
        let textHeight: CGFloat = 13
        let axisTopOffset = (textHeight + axisLabelOffset * 2) / -affine.d
        
        var maxY = (chartRect.maxY - axisTopOffset + 1).rounded()
        var maxYLastDigit: Int = 0

        repeat {
            maxY -= 1
            maxYLastDigit = Int(
                maxY
                .rounded()
                .truncatingRemainder(dividingBy: 10)
            )
        } while maxYLastDigit != 5 && maxYLastDigit != 0
        
        return maxY.rounded()
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
