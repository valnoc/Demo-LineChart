//
//  ChartMapper.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation

class ChartMapper {
    func map(from json: [[AnyHashable: Any]]) throws -> [Chart] {
        var result: [Chart] = []
        
        for object in json {
            //  columns
            guard let objectColumns = object["columns"] as? [[Any]] else { continue }
            var columns: [String: [Int]] = [:]
            for item in objectColumns {
                guard let key = item.first as? String,
                    let value = Array(item.dropFirst()) as? [Int] else { continue }
                columns[key] = value
            }
            
            guard let objectTypes = object["types"] as? [String: String] else { continue }
        }
        
        return result
    }
}
