//
//  Range+MapBounds.swift
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
