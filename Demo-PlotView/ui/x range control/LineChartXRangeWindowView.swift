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
        
        let point1 = CGPoint(x: horizontalBorderWidth / 2 + arrowWidth / 2,
                             y: rect.height / 2 - arrowHeight / 2)
        let point2 = CGPoint(x: horizontalBorderWidth / 2 - arrowWidth / 2,
                             y: rect.height / 2)
        let point3 = CGPoint(x: horizontalBorderWidth / 2 + arrowWidth / 2,
                             y: rect.height / 2 + arrowHeight / 2)
        
        let path = CGMutablePath()
        path.addLines(between: [point1, point2, point3])
        
        ctx.addPath(path)
        ctx.setLineWidth(2)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.strokePath()
        
        ctx.restoreGState()
    }
}
