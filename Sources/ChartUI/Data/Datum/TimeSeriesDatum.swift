//
//  TimeSeriesDatum.swift
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
