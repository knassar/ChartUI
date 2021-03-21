//
//  PointAxisMarker.swift
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

/// A type of decoration for points along an axis
public enum PointAxisMarker {

    /// A short mark perpendicular to the axis, from the axis origin up to `length` in points
    case axisTic(length: CGFloat = 5)

    /// A line perpendicular to the axis, from the axis origin extending past the point `extending` in points
    case toPoint(extending: CGFloat = 0)

    /// A line perpendicular to the axis, across the entire visible range of the chart
    case thruRange

}
