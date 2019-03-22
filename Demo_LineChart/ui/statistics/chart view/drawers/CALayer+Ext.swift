//
//  CALayer+Ext.swift
//  Demo_LineChart
//
//  Created by Valeriy Bezuglyy on 22/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import UIKit

extension CALayer {
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set(value){
            var frame = self.frame
            frame.origin = value
            self.frame = frame
        }
    }
}
