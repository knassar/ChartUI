//
//  Decorator.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// A protocol describing views which decorate points within a chart.
/// 
/// When creating a custom decorator for linear charts to highlight points, conform to this protocol to gain the `decoatedPoints` computed property which will supply the correctly-calculated centers for each decorated point within the chart layout.
public protocol PointDecorator: View {

    /// The environment's LinearChartLayout.
    ///
    /// Custom Decorators should bind to it using `@Environment(\.linearChartLayout)`
    var layout: LinearChartLayout { get }

    /// The points to be decorated
    var appliesTo: PointApplication { get }

}

extension PointDecorator {

    /// An array of applicable chart points, in the coordinate space of the chart view
    public var decoratedPoints: [CGPoint] {
        switch appliesTo {
        case .all:
            return layout.visibleDataPoints
        case .first where layout.isVisible(x: layout.absoluteDataBounds.start):
            return [layout.visibleDataPoints.first].compactMap { $0 }
        case .last where layout.isVisible(x: layout.absoluteDataBounds.end):
            return [layout.visibleDataPoints.last].compactMap { $0 }
        case let .each(dataPoints):
            return dataPoints.compactMap { layout.visibleLayoutPoint(for: $0) }
        default:
            return []
        }
    }

}

/// A representation of points to apply decorators to
public enum PointApplication {

    /// All points
    case all

    /// The first point in the sereis
    case first

    /// The last point in the series
    case last

    /// All specified points
    case each([AnyDatum])

}

/// A type of decoration for points along an axis
public enum PointAxisMarker {

    /// A short mark perpendicular to the axis, from the axis origin up to `length` in points
    case axisTic(length: CGFloat = 5)

    /// A line perpendicular to the axis, from the axis origin extending past the point `extending` in points
    case toPoint(extending: CGFloat = 0)

    /// A line perpendicular to the axis, across the entire visible range of the chart
    case thruRange

}
