//
//  PointSelection.swift
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

/// A representation of points to apply decorators to
public enum PointSelection {

    /// All points
    case all

    /// The first point in the sereis
    case first

    /// The last point in the series
    case last

    /// All specified points
    case each([AnyDatum])

}

extension LineChartLayout.Segment {


    /// Provide an array of concrete points within the segment layout indicated by `selection`
    ///
    /// This function is used by Decorators which need to selectivley highlight points in a chart, delegating the task
    /// of converting the specified `PointSelection`to the points in each segment.
    /// - Parameter selection: The configured `PointSelection` for the decorator
    /// - Returns: An array of points computed in layout-terms
    public func pointsToDecorate(in selection: PointSelection) -> [CGPoint] {
        switch selection {
        case .all:
            return points
        case .first where position.contains(.first):
            return [points.first].compactMap { $0 }
        case .last where position.contains(.last):
            return [points.last].compactMap { $0 }
        case let .each(datums):
            return points(for: datums)
        default:
            return []
        }
    }

}

