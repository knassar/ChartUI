//
//  TimeSeriesDatum.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// A datum associating a value with a `Date`, for charting values over time.
public enum TimeSeriesDatum<Value: DataValue>: OrderedDatum {

    /// A value for a given date
    case point(Value, at: Date)

    /// An invalid datum
    case invalid

    public var y: Value {
        switch self {
        case .invalid:
            return .absoluteMinimum
        case let .point(y, _):
            return y
        }
    }

    public var x: Date {
        switch self {
        case .invalid:
            return .absoluteMinimum
        case let .point(_, x):
            return x
        }
    }

    public var yValue: CGFloat {
        switch self {
        case .invalid:
            return .nan
        case let .point(y, _):
            return y.dataSeriesValue
        }
    }

    public var xValue: CGFloat {
        x.dataSeriesValue
    }

    public var isValid: Bool {
        self != .invalid
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x < rhs.x
    }

}
