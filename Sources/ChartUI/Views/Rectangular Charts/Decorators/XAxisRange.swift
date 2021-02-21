//
//  XAxisRange.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Renders a rectangular range in the X-axis (a vertical band) across a rectangular chart
public struct XAxisRange: View {

    private var minBound: CGFloat?
    private var maxBound: CGFloat?

    @Environment(\.lineChartLayout)
    private var layout: LineChartLayout

    @Environment(\.lineChartSegment)
    private var segment: LineChartLayout.Segment

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
                    LineSegment(start: CGPoint(x: rangeRect.minX, y: layout.localFrame.minY),
                                end: CGPoint(x: rangeRect.minX, y: layout.localFrame.maxY))
                        .strokeBorder(stroke, lineWidth: style.rangeStrokeWidth)

                }
                if maxBound != nil {
                    LineSegment(start: CGPoint(x: rangeRect.maxX, y: layout.localFrame.minY),
                                end: CGPoint(x: rangeRect.maxX, y: layout.localFrame.maxY))
                        .strokeBorder(stroke, lineWidth: style.rangeStrokeWidth)

                }
            }
        }
        .animation(.default)
    }

    private var rangeRect: CGRect {
        CGRect(x: scaledMinX, y: layout.localFrame.minY,
                    width: scaledMaxX - scaledMinX, height: layout.localFrame.height)
    }

    private var scaledMinX: CGFloat {
        if let minBound = minBound, segment.isVisible(x: minBound) {
            return layout.xInLayout(fromDataX: minBound)
        } else {
            return 0
        }
    }

    private var scaledMaxX: CGFloat {
        if let maxBound = maxBound, segment.isVisible(x: maxBound) {
            return layout.xInLayout(fromDataX: maxBound)
        } else {
            return layout.localFrame.maxX
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

struct XAxisRange_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {

        LibraryItem(XAxisRange(10...30),
                    title: "X-Axis Range Decorator",
                    category: .other)

    }

}

struct XAxisRange_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries, trimmedTo: .previousWeek, underlay: ZStack {
            XAxisRange(...Date.today.dayBefore.dayBefore)
                .rectChartRange(fill: Color.red.opacity(0.2))
                .rectChartRange(stroke: .red)
            XAxisRange(Date.today.dayBefore...)
        })
            .rectChartRange(fill: Color.green.opacity(0.2))
            .rectChartRange(stroke: .blue)
            .frame(width: 300, height: 150)
    }
}
