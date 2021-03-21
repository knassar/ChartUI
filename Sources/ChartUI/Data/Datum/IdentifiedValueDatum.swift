//
//  IdentifiedValueDatum.swift
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

/// A datum associating a `Value` with an `Id`, for charting counts in identifiable categories.
///
/// The `Id` generic constraint specifies an `InvalidatableId`, allowing the `id` property of this type to meet requirments by both `Identifiable` and `Datum`.
public enum IdentifiedValueDatum<Id: InvalidatableId, Value: DataValue>: CategorizedDatum {

    /// A count for a given name
    case count(Value, for: Id)

    /// an invalid datum
    case invalid

    public var y: Value {
        switch self {
        case let .count(y, _):
            return y
        case .invalid:
            return .absoluteMinimum
        }
    }

    public var id: Id {
        switch self {
        case let .count(_, id):
            return id
        case .invalid:
            return .invalidId
        }
    }

    public var xValue: CGFloat { .nan }

    public var yValue: CGFloat {
        switch self {
        case let .count(y, _):
            return y.dataSeriesValue
        case .invalid:
            return .nan
        }
    }

    public var isValid: Bool {
        switch self {
        case .count:
            return true
        case .invalid:
            return false
        }
    }

}

/// A protocol providing conformance with `Indentifiable.Id`, with the additional ability to express a state of "invalidity".
///
/// Consumers may conform custom types to this protocol, but be mindful of the chosen expression of `invalidId` (including its `hashValue`) to avoid conflicts with valid `Id`s
public protocol InvalidatableId: Hashable {

    /// A value of this type which does not equate or hash-conflict with with a valid Identity value.
    static var invalidId: Self { get }

}

extension String: InvalidatableId {

    public static let invalidId: String = ""

}

extension Int: InvalidatableId {

    // The use here of `Int.min` as an invalid Id is arguably tenuous, but as most uses of `Int` as an `Identifiable.Id` conformance would be assumed to be unsigned, it's deemed safe-enough for our purposes.
    public static let invalidId: Int = .min

}

extension Double: InvalidatableId {

    // This is an ideal conformance, since `.nan` is never equal to any Double, including other `.nan` values
    public static let invalidId: Double = .nan

}
