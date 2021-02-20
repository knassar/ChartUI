//
//  XAxisGridView.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Configuration for the X-axis grid in a rectangular chart
public struct XAxisGrid {

    var origin: CGFloat = 0
    var originIsAbsolute: Bool
    var gridSpacing: CGFloat
    var color: Color = Color(red: 0.6, green: 0.85, blue: 1.0, opacity: 1)


    /// Initialize a configuration for the X-axis grid
    ///
    /// Grid dimensions are always specified in terms of the `DataValue` for the X-axis of the chart in question. The chart layout will perform all calculations to transform the grid values to rendered layout coordinates.
    /// - Parameters:
    ///   - origin: An optional origin for the X axis. If un-specified, the grid will default to the natural origin (0)
    ///   - spacing: The distance between grid lines
    ///   - color: A color for grid lines. If un-specified, a cyan is used.
    public init<X: DataValue>(origin: X? = nil, spacing: X, color: Color? = nil) {
        self.gridSpacing = spacing.dataSeriesValue
        if let origin = origin {
            self.origin = origin.dataSeriesValue
        }
        self.originIsAbsolute = false
        if let color = color {
            self.color = color
        }
    }

    /// Initialize a configuration for the X-axis grid for TimeSeries data
    ///
    /// Because it is very common to orient a time-series chart with dates in the X-axis, this initializer allows you to specify the origin in terms of an absolute `Date`, while specifying the grid spacing in terms of a `TimeInterval`.
    /// The chart layout will perform all calculations to transform the grid values to rendered layout coordinates.
    /// - Parameters:
    ///   - origin: A origin `Date` for the X axis.
    ///   - spacing: The distance between grid lines
    ///   - color: A color for grid lines. If un-specified, a cyan is used.
   public init(origin: Date, spacing: TimeInterval, color: Color? = nil) {
        self.gridSpacing = spacing.dataSeriesValue
        self.origin = origin.dataSeriesValue
        self.originIsAbsolute = true
        if let color = color {
            self.color = color
        }
    }
}

struct XAxisGridView: View {

    var grid: XAxisGrid

    @Environment(\.linearChartLayout)
    private var layout: LinearChartLayout

    var body: some View {
        ForEach(gridLines(grid), id: \.self) { x in
            lineSegment(at: x)
                .strokeBorder(grid.color, lineWidth: 0.5)
        }
    }

    private func gridLines(_ grid: XAxisGrid) -> [CGFloat] {
        var lines = [CGFloat]()
        let step = grid.gridSpacing
        var x = gridOriginX
        while x <= layout.visibleDataBounds.end {
            lines.append(x)
            x += step
        }
        x = gridOriginX
        while x >= layout.visibleDataBounds.start {
            lines.append(x)
            x -= step
        }
        return lines
    }

    private func lineSegment(at x: CGFloat) -> LineSegment {
        let x = layout.xInLayout(fromDataX: x)
        return LineSegment(start: CGPoint(x: x, y: layout.localFrame.minY),
                           end: CGPoint(x: x, y: layout.localFrame.maxY))
    }

    private var gridOriginX: CGFloat {
        grid.originIsAbsolute
            ? grid.origin
            : layout.origin.x + grid.origin
    }

    private var originVisible: Bool {
        layout.isVisible(x: gridOriginX)
    }

}

struct XAxisGridView_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries, trimmedTo: .previousWeek)
            .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: .days(1)))
            .chartInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .frame(width: 300, height: 150)
            .border(Color.black)
    }
}
