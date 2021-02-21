//
//  PointAxisMarker.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
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
