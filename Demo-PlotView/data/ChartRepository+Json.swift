//
//  ChartDataRepository.swift
//  Demo-PlotView
//
//  Created by Valeriy Bezuglyy on 17/03/2019.
//  Copyright © 2019 Valeriy Bezuglyy. All rights reserved.
//

import Foundation

extension ChartRepository {
    // MARK: - read json
    struct JsonDataNotFound: Error {}
    struct InvalidJsonData: Error {}
    
    func readJson() throws -> [[AnyHashable: Any]] {
        guard let path = Bundle.main.path(forResource: "chart_data", ofType: "json") else { throw JsonDataNotFound() }
        let url = URL(fileURLWithPath: path)
        
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let result = json as? [[AnyHashable: Any]] else { throw InvalidJsonData() }
        return result
    }
}
