//
//  LineChartLabelDrawer.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 22/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

class LineChartLabelDrawer {
    func makeTextLayer(text: String,
                       font: UIFont = UIFont.systemFont(ofSize: 13),
                       fontSize: CGFloat = 13,
                       color: UIColor = UIColor(red: 144.0 / 255.0,
                                                green: 150 / 255.0,
                                                blue: 156 / 255.0,
                                                alpha: 1)) -> CATextLayer {
        let labelLayer = CATextLayer()
        labelLayer.font = font
        labelLayer.fontSize = fontSize
        labelLayer.string = text
        labelLayer.foregroundColor = color.cgColor
        labelLayer.contentsScale = UIScreen.main.scale
        
        var frame = labelLayer.frame
        frame.size = labelLayer.preferredFrameSize()
        labelLayer.frame = frame
        
        return labelLayer
    }
}
