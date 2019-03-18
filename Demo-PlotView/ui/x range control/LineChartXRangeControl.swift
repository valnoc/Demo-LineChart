//
//  LineChartXRangeControl.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 18/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartXRangeControl : UIControl {
    
    let chartView: LineChartView
    
    let windowVerticalBorderWidth: CGFloat = 3
    let windowHorizontalBorderWidth: CGFloat = 11
    let windowLeftX: CGFloat = 10
    let windowRightX: CGFloat = 50
    
    init(chart: LineChart) {
        self.chartView = LineChartView(chart: chart)
        super.init(frame: .zero)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)
        backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds.insetBy(dx: 0, dy: windowVerticalBorderWidth)
    }
 
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        drawWindow(rect, ctx)
    }
    
    func drawWindow(_ rect: CGRect, _ ctx: CGContext) {
        ctx.saveGState()
        
        ctx.setFillColor(UIColor(red: 195.0 / 255.0,
                                 green: 206.0 / 255.0,
                                 blue: 217.0 / 255.0,
                                 alpha: 1).cgColor)
        ctx.addPath(CGPath(roundedRect: CGRect(x: windowLeftX,
                                               y: 0,
                                               width: windowRightX - windowLeftX,
                                               height: rect.height),
                           cornerWidth: 1,
                           cornerHeight: 1,
                           transform: nil))
        ctx.fillPath()
        ctx.restoreGState()
    }
}
