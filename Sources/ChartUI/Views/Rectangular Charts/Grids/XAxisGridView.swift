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

    var segment: LineChartLayout.Segment

    @Environment(\.rectangularChartLayout)
    private var rectLayout: RectangularChartLayout

    @Environment(\.lineChartLayout)
    private var lineLayout: LineChartLayout

    var body: some View {
        GridLines(segment: segment, grid: grid, lineLayout: lineLayout, rectLayout: rectLayout)
            .animation(.default)
            .foregroundColor(grid.color)
    }

    private struct GridLines: InsettableShape {

        var segment: LineChartLayout.Segment
        var grid: XAxisGrid
        var lineLayout: LineChartLayout
        var rectLayout: RectangularChartLayout

        var animatableData: LineChartLayout.Segment.AnimatableData {
            get { segment.animatableData }
            set { segment.animatableData = newValue }
        }

        func inset(by amount: CGFloat) -> some InsettableShape {
            self
        }

        func path(in rect: CGRect) -> Path {
            var path = Path()
            for x in gridLines(grid) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: rectLayout.localFrame.height))
            }
            return path.strokedPath(StrokeStyle(lineWidth: 0.5))
        }

        private func gridLines(_ grid: XAxisGrid) -> [CGFloat] {
            var lines = [CGFloat]()
            let step = grid.gridSpacing
            var x = firstOriginAlignedX
            while x <= endPoint {
                lines.append(x)
                x += step
            }
            return lines.map {
                segment.xInSegment(fromDataX: $0)
            }
        }

        private var firstOriginAlignedX: CGFloat {
            var x = gridOriginX
            while x > startPoint  {
                x -= grid.gridSpacing
            }
            while x < startPoint  {
                x += grid.gridSpacing
            }
            return x
        }

        private var gridOriginX: CGFloat {
            grid.originIsAbsolute
                ? grid.origin
                : rectLayout.origin.x + grid.origin
        }

        private var startPoint: CGFloat {
            segment.position.contains(.first)
                ? lineLayout.xDataBoundsWithInsets.lowerBound
                : segment.startX
        }

        private var endPoint: CGFloat {
            segment.position.contains(.last)
                ? lineLayout.xDataBoundsWithInsets.upperBound
                : segment.endX
        }

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
