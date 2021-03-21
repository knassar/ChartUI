//
//  AnyDataSeries.swift
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
import CoreGraphics

public protocol AnyDataSeries {

    /// `true` if the series is empty
    var isEmpty: Bool { get }

    /// The count of the series data
    var count: Int { get }

    /// The first datum in the series (if `CategorizedDatum`), or the datum with the lowest `xValue` value (if `OrderedDatum`)
    var first: AnyDatum { get }

    /// The last datum in the series (if `CategorizedDatum`), or the datum with the highest `xValue` value (if `OrderedDatum`)
    var last: AnyDatum { get }

    /// The datum with the lowest `yValue`
    var minimum: AnyDatum { get }

    /// The datum with the highest `yValue`
    var maximum: AnyDatum { get }

    /// A collection of type-erased data
    var allData: [AnyDatum] { get }

}

extension AnyDataSeries {

    /// Tests an `X` value for coverage by the series. Note that this returns `true` if the supplied value is covered by the range of the series, even if it does not represent a discrete datum.
    /// - Parameter x: An `X` to test
    /// - Returns: `true` if the supplied `x` value is between the series `minimum` and `maximum`
    public func contains<X: Comparable>(x: X) -> Bool {
        guard let firstX = first.datum as? X,
              let lastX = last.datum as? X
        else { return false }

        return (firstX...lastX).contains(x)
    }

}
