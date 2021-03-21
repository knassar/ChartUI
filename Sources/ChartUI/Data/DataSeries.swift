//
//  DataSeries.swift
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

/// A structured collection of data values for visualization in a chart
public struct DataSeries<P: Datum>: AnyDataSeries {

    public var isEmpty: Bool {
        data.isEmpty
    }

    public var count: Int {
        data.count
    }

    public private(set) var first: AnyDatum = .invalid
    public private(set) var last: AnyDatum = .invalid
    public private(set) var minimum: AnyDatum = .invalid
    public private(set) var maximum: AnyDatum = .invalid

    /// The data collection in the native type
    public private(set) var data: [P]

    public var allData: [AnyDatum] {
        data.map { AnyDatum($0) }
    }

    /// Initializes a `DataSeries` with data of the supplied type
    /// - Parameter data: An array of points conforming to `Datum`
    public init(data: [P]) {
        self.data = data
        recalculate()
    }

}

extension DataSeries: AnyCategorizedDataSeries where P: CategorizedDatum {

    public var categorizedData: [AnyCategorizedDatum] {
        (0..<data.count).map {
            AnyCategorizedDatum(data[$0], index: $0)
        }
    }

}

// MARK: - Queries


extension DataSeries where P: OrderedDatum {

    /// Filters the series by applying the condition sequentially to each `X` value, available when the datum type is a `OrderedDatum`
    /// - Parameter condition: A test which should return `true` for all `X`s to retrieve
    /// - Returns: A collection of all datums in the collection which meet the `condition`, type-erased to `AnyDatum`
    public func allX<X: DataValue>(where condition: (X) -> Bool) -> [AnyDatum] where X == P.X {
        data.filter { condition($0.x) }.map { AnyDatum($0) }
    }

    /// Filters the series by applying the condition sequentially to each `Y` value
    /// - Parameter condition: A test which should return `true` for all `Y`s to retrieve
    /// - Returns: A collection of all datums in the collection which meet the `condition`, type-erased to `AnyDatum`
    public func allY<Y: DataValue>(where condition: (Y) -> Bool) -> [AnyDatum] where Y == P.Y {
        data.filter { condition($0.y) }.map { AnyDatum($0) }
    }

}

extension DataSeries where P: CategorizedDatum {

    /// Filters the series by applying the condition sequentially to each index, available when the datum type is a `CategorizedDatum`
    /// - Parameter condition: A test which should return `true` for all indicies s to retrieve
    /// - Returns: A collection of all datums in the collection which meet the `condition`, type-erased to `AnyDatum`
    public func allX(where condition: (Int) -> Bool) -> [AnyDatum] {
        (0..<data.count).filter { condition($0) }.map { AnyDatum(data[$0]) }
    }

    /// Finds the index of the datum by its `Id`. Available when the datum type is a `CategorizedDatum`
    /// - Parameter datum: A datum
    /// - Returns: The index of the datum within the data series or `nil` if not found
    public func index(for datum: P) -> Int? {
        data.firstIndex { $0.id == datum.id }
    }

    /// Filters the series by applying the condition sequentially to each `Y` value
    /// - Parameter condition: A test which should return `true` for all `Y`s to retrieve
    /// - Returns: A collection of all datums in the collection which meet the `condition`, type-erased to `AnyDatum`
    public func allY<Y: DataValue>(where condition: (Y) -> Bool) -> [AnyDatum] where Y == P.Y {
        data.filter { condition($0.y) }.map { AnyDatum($0) }
    }

}

// MARK: - Manipultations

extension DataSeries {

    /// Returns a new data series by appending the supplied data
    /// - Parameter data: data to append
    /// - Returns: A new `DataSeries` with the new data appended to the previous
    public func appending(_ data: P...) -> Self {
        appending(data: data)
    }

    /// Returns a new data series by appending the supplied data
    /// - Parameter data: data to append
    /// - Returns: A new `DataSeries` with the new data appended to the previous
    public func appending(data: [P]) -> Self {
        var series = self
        series.data.append(contentsOf: data)
        series.recalculate()
        return series
    }

}

// MARK: - Calculations

extension DataSeries where P: Datum {

    private mutating func recalculate() {
        data.sort { $0.xValue < $1.xValue }
        self.minimum = .invalid
        self.maximum = .invalid

        if data.isEmpty {
            self.first = .invalid
            self.last = .invalid
        } else {
            self.first = AnyDatum(data.first!)
            self.last = AnyDatum(data.last!)
        }

        data.forEach { datum in
            if !minimum.isValid || datum.yValue < minimum.yValue {
                minimum = AnyDatum(datum)
            }
            if !maximum.isValid || datum.yValue > maximum.yValue {
                maximum = AnyDatum(datum)
            }
        }
    }

    func isValid(_ datum: P?) -> Bool {
        datum != nil && datum!.isValid
    }

}

extension DataSeries where P: CategorizedDatum {

    /// Subscript access to the data by datum `Id`
    public subscript(datum id: P.ID) -> P? {
        data.first { $0.id == id }
    }

    private mutating func recalculate() {

        self.minimum = .invalid
        self.maximum = .invalid

        self.first = AnyDatum(data.first ?? .invalid, index: 0)
        self.last = AnyDatum(data.last ?? .invalid, index: data.count - 1)

        for i in 0..<data.count {
            if !minimum.isValid || data[i].yValue < minimum.yValue {
                minimum = AnyDatum(data[i], index: i)
            }
            if !maximum.isValid || data[i].yValue > maximum.yValue {
                maximum = AnyDatum(data[i], index: i)
            }
        }
    }

    func point(for datum: P) -> CGPoint {
        guard let index = data.firstIndex(where: { $0.id == datum.id }) else {
            return CGPoint(x: .nan, y: datum.yValue)
        }
        return CGPoint(x: CGFloat(index), y: datum.yValue)
    }

    func isValid(_ datum: P?) -> Bool {
        datum != nil && datum!.isValid
    }

}
