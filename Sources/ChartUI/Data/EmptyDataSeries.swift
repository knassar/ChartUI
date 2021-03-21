//
//  EmptyDataSeries.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2019 HungryMelonStudios LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//      http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import SwiftUI

struct EmptyDataSeries: AnyCategorizedDataSeries {

    let allData: [AnyDatum] = []
    let count = 0
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
