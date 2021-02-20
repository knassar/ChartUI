//
//  EmptyDataSeries.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import Foundation
import SwiftUI

struct EmptyDataSeries: AnyCategorizedDataSeries {

    let allData: [AnyDatum] = []
    let isEmpty: Bool = true
    let first: AnyDatum = .invalid
    let last: AnyDatum = .invalid
    let minimum: AnyDatum = .invalid
    let maximum: AnyDatum = .invalid
    let xType: Any.Type = Double.self
    let yType: Any.Type = Double.self
    let categorizedData: [AnyCategorizedDatum] = []

    func contains<X>(x: X) -> Bool {
        false
    }

    func isVisible<X>(x: X) -> Bool {
        false
    }

    public func allX<X: DataValue>(where condition: (X) -> Bool) -> [AnyDatum] {
        []
    }

    public func allY<Y: DataValue>(where condition: (Y) -> Bool) -> [AnyDatum] {
        []
    }

}
