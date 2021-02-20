//
//  Range+MapBounds.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import Foundation

extension Range {

    func mapBounds<U: Comparable>(_ operation: (Bound) -> U) -> Range<U> {
        operation(lowerBound)..<operation(upperBound)
    }

}

extension ClosedRange {

    func mapBounds<U: Comparable>(_ operation: (Bound) -> U) -> ClosedRange<U> {
        operation(lowerBound)...operation(upperBound)
    }

}

extension PartialRangeFrom {

    func mapBounds<U: Comparable>(_ operation: (Bound) -> U) -> PartialRangeFrom<U> {
        operation(lowerBound)...
    }

}

extension PartialRangeUpTo {

    func mapBounds<U: Comparable>(_ operation: (Bound) -> U) -> PartialRangeUpTo<U> {
        ..<operation(upperBound)
    }

}

extension PartialRangeThrough {

    func mapBounds<U: Comparable>(_ operation: (Bound) -> U) -> PartialRangeThrough<U> {
        ...operation(upperBound)
    }

}
