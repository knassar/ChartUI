//
//  Datum.swift
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

import SwiftUI

/// A datum capable of being represented in a chart
public protocol Datum {

    /// The x value in absolute terms
    var xValue: CGFloat { get }

    /// The y value in absolute terms
    var yValue: CGFloat { get }

    /// `true` if the datum is valid
    var isValid: Bool { get }

}

/// A `Datum` which maps a y component `Y` against an x component `X`
public protocol OrderedDatum: Datum, Comparable {

    /// The type of the x component
    associatedtype X: DataValue

    /// The type of the y component
    associatedtype Y: DataValue

    /// The x component
    var x: X { get }

    /// The y component
    var y: Y { get }

    /// An instance of this type for which `isValid` is always `false`
    static var invalid: Self { get }

}

/// A `Datum` which maps a y component `Y` against an identifier `Id` unique within a data series
public protocol CategorizedDatum: Datum, Identifiable {

    /// The type of the y component
    associatedtype Y: DataValue

    /// The y component
    var y: Y { get }

    /// An instance of this type for which `isValid` is always `false`
    static var invalid: Self { get }

}

/// A type-erased wrapper for any `Datum`
public struct AnyDatum: Datum, Equatable {

    let datum: Datum

    /// the wrapped datum's `xValue`
    public var xValue: CGFloat

    /// the wrapped datum's `yValue`
    public var yValue: CGFloat

    /// the wrapped datum's `isValid`
    public var isValid: Bool

    /// a type-erased datum who's `isValid` is always false
    static let invalid = Self(InvalidDatum())

    init<D>(_ datum: D, index: Int) where D: CategorizedDatum {
        self.datum = datum
        self.xValue = CGFloat(index)
        self.yValue = datum.yValue
        self.isValid = datum.isValid
    }

    init(_ datum: Datum) {
        self.datum = datum
        self.xValue = datum.xValue
        self.yValue = datum.yValue
        self.isValid = datum.isValid
    }

    public static func == (lhs: AnyDatum, rhs: AnyDatum) -> Bool {
        lhs.xValue == rhs.xValue && lhs.yValue == rhs.yValue
    }

}

/// A type-erased wrapper for any `CategorizedDatum`
public struct AnyCategorizedDatum: Datum, Identifiable {

    let datum: Datum

    /// the wrapped datum's type-erased `id`
    public var id: AnyHashable

    /// the wrapped datum's index within the `DataSeries` it was retrieved from
    public var index: Int

    /// the wrapped datum's `yValue`
    public var yValue: CGFloat

    /// the wrapped datum's `isValid`
    public var isValid: Bool

    public var xValue: CGFloat {
        CGFloat(index)
    }

    /// a type-erased datum who's `isValid` is always false
    static let invalid = Self(InvalidDatum(), index: .min)

    init<D: CategorizedDatum>(_ datum: D, index: Int) {
        self.datum = datum
        self.id = AnyHashable(datum.id)
        self.index = index
        self.yValue = datum.yValue
        self.isValid = datum.isValid
    }

}

struct InvalidDatum: Datum, CategorizedDatum {

    let id: Double = .nan
    let xValue: CGFloat = .nan
    let yValue: CGFloat = .nan
    let y: Double = .nan
    let isValid: Bool = false

    static let invalid = InvalidDatum()

}
