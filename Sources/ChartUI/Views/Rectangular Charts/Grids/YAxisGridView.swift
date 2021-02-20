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

    @Environment(\.linearChartLayout)
    private var layout: LinearChartLayout

    var body: some View {
        ForEach(gridLines(grid), id: \.self) { y in
            lineSegment(at: y)
                .strokeBorder(grid.color, lineWidth: 0.5)
        }
    }

    private func gridLines(_ grid: YAxisGrid) -> [CGFloat] {
        var lines = [CGFloat]()
        let step = grid.gridSpacing
        var y = gridOriginY
        while y <= layout.visibleDataBounds.maximum {
            lines.append(y)
            y += step
        }
        y = gridOriginY
        while y >= layout.visibleDataBounds.minimum {
            y -= step
            lines.append(y)
        }
        return lines
    }

    private func lineSegment(at y: CGFloat) -> LineSegment {
        let y = layout.yInLayout(fromDataY: y)
        return LineSegment(start: CGPoint(x: layout.localFrame.minX, y: y),
                           end: CGPoint(x: layout.localFrame.maxX, y: y))
    }

    private var gridOriginY: CGFloat {
        layout.origin.y + grid.origin
    }

    private var originVisible: Bool {
        layout.isVisible(y: gridOriginY)
    }

}

struct YAxisGridView_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries)
            .frame(width: 300, height: 150)
            .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
    }
}
