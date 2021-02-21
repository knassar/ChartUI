//
//  YAxisRange.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Renders a rectangular range in the Y-axis (a horizontal band) across a rectangular chart
public struct YAxisRange: View {

    private var minBound: CGFloat?
    private var maxBound: CGFloat?

    @Environment(\.rectangularChartLayout)
    private var layout: RectangularChartLayout

    @Environment(\.rectangularChartStyle)
    private var style: RectangularChartStyle

    public var body: some View {
        let rangeRect = self.rangeRect
        ZStack {
            if let fill = style.rangeFill {
                RectangularRange(rangeRect)
                    .fill(fill)
            }
            if let stroke = style.rangeStroke {
                if minBound != nil {
                    LineSegment(start: CGPoint(x: layout.localFrame.minX, y: rangeRect.maxY),
                                end: CGPoint(x: layout.localFrame.maxX, y: rangeRect.maxY))
                        .strokeBorder(stroke, lineWidth: style.rangeStrokeWidth)

                }
                if maxBound != nil {
                    LineSegment(start: CGPoint(x: layout.localFrame.minX, y: rangeRect.minY),
                                end: CGPoint(x: layout.localFrame.maxX, y: rangeRect.minY))
                        .strokeBorder(stroke, lineWidth: style.rangeStrokeWidth)

                }
            }
        }
        .animation(.default)
    }

    private var rangeRect: CGRect {
        CGRect(x: layout.localFrame.minX, y: scaledMinY,
               width: layout.localFrame.width, height: scaledMaxY - scaledMinY)
            .standardized
    }

    private var scaledMinY: CGFloat {
        if let minBound = minBound, layout.isVisible(y: minBound) {
            return layout.yInLayout(fromDataY: minBound)
        } else {
            return layout.localFrame.maxY
        }
    }

    private var scaledMaxY: CGFloat {
        if let maxBound = maxBound, layout.isVisible(y: maxBound) {
            return layout.yInLayout(fromDataY: maxBound)
        } else {
            return layout.localFrame.minY
        }
    }

    /// Initializes the rectangular range
    /// - Parameter range: The range of values in terms of the chart data to highlight
    public init<T: DataValue>(_ range: Range<T>) {
        self.minBound = range.lowerBound.dataSeriesValue
        self.maxBound = range.upperBound.dataSeriesValue - 0.01
    }

    /// Initializes the rectangular range
    /// - Parameter range: The range of values in terms of the chart data to highlight
    public init<T: DataValue>(_ range: ClosedRange<T>) {
        self.minBound = range.lowerBound.dataSeriesValue
        self.maxBound = range.upperBound.dataSeriesValue
    }

    /// Initializes the rectangular range
    /// - Parameter range: The range of values in terms of the chart data to highlight
    public init<T: DataValue>(_ range: PartialRangeFrom<T>) {
        self.minBound = range.lowerBound.dataSeriesValue
        self.maxBound = nil
    }

    /// Initializes the rectangular range
    /// - Parameter range: The range of values in terms of the chart data to highlight
    public init<T: DataValue>(_ range: PartialRangeUpTo<T>) {
        self.minBound = nil
        self.maxBound = range.upperBound.dataSeriesValue - 0.01
    }

    /// Initializes the rectangular range
    /// - Parameter range: The range of values in terms of the chart data to highlight
    public init<T: DataValue>(_ range: PartialRangeThrough<T>) {
        self.minBound = nil
        self.maxBound = range.upperBound.dataSeriesValue
    }

}

struct YAxisRange_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {

        LibraryItem(YAxisRange(10...20),
                    title: "Y-Axis Range Decorator",
                    category: .other)

    }

}

struct YAxisRange_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries, trimmedTo: .previousWeek, underlay: ZStack {
            XAxisRange(Date.today.dayBefore.dayBefore...Date.today.dayBefore)
                .rectChartRange(fill: Color.green.opacity(0.2))
                .rectChartRange(stroke: .green)

            YAxisRange(80...)
                .rectChartRange(fill: Color.red.opacity(0.2))
                .rectChartRange(stroke: .red)

            YAxisRange(60...100)
                .rectChartRange(fill: Color.red.opacity(0.2))
                .rectChartRange(stroke: .green)

            YAxisRange(...80)
        })
            .rectChartRange(stroke: .blue)
            .rectChartRange(strokeWidth: 1)
            .chartInsets(.all)
            .frame(width: 300, height: 150)
    }
}
