//
//  AnyDataSeries.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
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
