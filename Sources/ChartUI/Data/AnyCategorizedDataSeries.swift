//
//  AnyCategorizedDataSeries.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import Foundation

public protocol AnyCategorizedDataSeries: AnyDataSeries {

    /// the data type-erased to `AnyCategorizedDatum` available if the series' data type is `CategorizedDatum`
    var categorizedData: [AnyCategorizedDatum] { get }

}

extension AnyCategorizedDataSeries {

    func datum(at index: Int) -> AnyCategorizedDatum? {
        guard index < categorizedData.count else { return nil }
        return categorizedData[index]
    }

}
