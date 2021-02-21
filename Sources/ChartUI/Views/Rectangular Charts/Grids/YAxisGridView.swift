//
//  YAxisGridView.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Configuration for the Y-axis grid in a rectangular chart
public struct YAxisGrid {

    var origin: CGFloat = 0
    var gridSpacing: CGFloat
    var color: Color = Color(white: 0.75, opacity: 1)

    /// Initialize a configuration for the Y-axis grid
    ///
    /// Grid dimensions are always specified in terms of the `DataValue` for the Y-axis of the chart in question. The chart layout will perform all calculations to transform the grid values to rendered layout coordinates.
    /// - Parameters:
    ///   - origin: An optional origin for the Y axis. If un-specified, the grid will default to the natural origin (0)
    ///   - spacing: The distance between grid lines
    ///   - color: A color for grid lines. If un-specified, a medium gray is used.private
    public init<Y: DataValue>(origin: Y? = nil, spacing: Y, color: Color? = nil) {
        self.gridSpacing = spacing.dataSeriesValue
        if let origin = origin {
            self.origin = origin.dataSeriesValue
        }
        if let color = color {
            self.color = color
        }
    }
}

struct YAxisGridView: View {

    var grid: YAxisGrid

    var segment: LineChartLayout.Segment?

    init(grid: YAxisGrid, segment: LineChartLayout.Segment? = nil) {
        self.grid = grid
        self.segment = segment
    }

    @Environment(\.rectangularChartLayout)
    private var layout: RectangularChartLayout

    var body: some View {
        ForEach(gridLines(grid), id: \.self) { y in
            lineSegment(at: y)
                .strokeBorder(grid.color, lineWidth: 0.5)
        }
    }

    private func gridLines(_ grid: YAxisGrid) -> [CGFloat] {
        var lines = [CGFloat]()
        let step = grid.gridSpacing
        var y = firstOriginAlignedY
        while y <= layout.yDataBoundsWithInsets.upperBound {
            lines.append(y)
            y += step
        }
        return lines.map {
            layout.yInLayout(fromDataY: $0)
        }
    }

    private func lineSegment(at y: CGFloat) -> LineSegment {
        return LineSegment(start: CGPoint(x: minX, y: y),
                           end: CGPoint(x: maxX, y: y))
    }

    private var firstOriginAlignedY: CGFloat {
        var y = gridOriginY
        while y > layout.yDataBoundsWithInsets.lowerBound  {
            y -= grid.gridSpacing
        }
        while y <= layout.yDataBoundsWithInsets.lowerBound - 1 {
            y += grid.gridSpacing
        }
        return y
    }

    private var gridOriginY: CGFloat {
        layout.origin.y + grid.origin
    }

    private var originVisible: Bool {
        layout.isVisible(y: gridOriginY)
    }

    private var minX: CGFloat {
        guard let segment = segment, !segment.position.contains(.first) else {
            return layout.localFrame.minX
        }
        return segment.rect.minX
    }

    private var maxX: CGFloat {
        guard let segment = segment, !segment.position.contains(.last) else {
            return layout.localFrame.maxX
        }
        return segment.rect.maxX
    }

}

struct YAxisGridView_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries)
            .frame(width: 300, height: 150)
            .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
    }
}
