//
//  LineChartXRangeWindowView.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartXRangeWindowView: UIView {
    let verticalBorderWidth: CGFloat = 1
    let horizontalBorderWidth: CGFloat = 11
    
    init() {
        super.init(frame: .zero)

        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        drawBorders(rect, ctx)
        drawArrows(rect, ctx)
    }
    
    func drawBorders(_ rect: CGRect, _ ctx: CGContext) {
        ctx.saveGState()
        
        let path = CGMutablePath()
        path.addRoundedRect(in: rect, cornerWidth: 1, cornerHeight: 1)
        path.addRect(
            rect.inset(by:
                UIEdgeInsets(top: verticalBorderWidth,
                             left: horizontalBorderWidth,
                             bottom: verticalBorderWidth,
                             right: horizontalBorderWidth)
            )
        )
        ctx.setFillColor(UIColor(red: 195.0 / 255.0,
                                 green: 206.0 / 255.0,
                                 blue: 217.0 / 255.0,
                                 alpha: 1).cgColor)
        ctx.addPath(path)
        ctx.fillPath(using: .evenOdd)
        
        ctx.restoreGState()
    }
    
    func drawArrows(_ rect: CGRect, _ ctx: CGContext) {
        ctx.saveGState()
        
        let arrowWidth: CGFloat = 4
        let arrowHeight: CGFloat = 11
        
        let borderWidth = horizontalBorderWidth
        let borderHeight = rect.height
        
        let p1 = CGPoint(x: borderWidth / 2 + arrowWidth / 2,
                         y: borderHeight / 2 - arrowHeight / 2)
        let p2 = CGPoint(x: borderWidth / 2 - arrowWidth / 2,
                         y: borderHeight / 2)
        let p3 = CGPoint(x: borderWidth / 2 + arrowWidth / 2,
                         y: borderHeight / 2 + arrowHeight / 2)
        
        let p4 = CGPoint(x: rect.width - p1.x,
                         y: p1.y)
        let p5 = CGPoint(x: rect.width - p2.x,
                         y: p2.y)
        let p6 = CGPoint(x: rect.width - p3.x,
                         y: p3.y)
        
        let path = CGMutablePath()
        path.addLines(between: [p1, p2, p3])
        path.addLines(between: [p4, p5, p6])
        
        ctx.addPath(path)
        ctx.setLineWidth(2)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.strokePath()
        
        ctx.restoreGState()
    }
}
