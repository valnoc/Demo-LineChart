//
//  UIColor+Hex.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hex = String(hex.dropFirst())

        let greenIndex = hex.index(hex.startIndex, offsetBy: 2)
        let blueIndex = hex.index(hex.startIndex, offsetBy: 4)
        
        let hexRed = String(hex[..<greenIndex])
        let hexGreen = String(hex[greenIndex ..< blueIndex])
        let hexBlue = String(hex[blueIndex...])
        
        guard let red = Double("0x\(hexRed)"),
            let green = Double("0x\(hexGreen)"),
            let blue = Double("0x\(hexBlue)") else {
                self.init(red: 0, green: 0, blue: 0, alpha: 1)
                return
        }
        
        self.init(red: CGFloat(red / 255.0),
                  green: CGFloat(green / 255.0),
                  blue: CGFloat(blue / 255.0),
                  alpha: 1)
    }
}
