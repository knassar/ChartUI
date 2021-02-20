//
//  LineChart.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Chart an Ordered DataSeries over a given range
public struct LineChart<P: OrderedDatum, Underlay: View, Overlay: View>: View {

    private var data: DataSeries<P>

    private var xRange: Range<CGFloat>?

    private var underlay: Underlay?

    private var overlay: Overlay?

    @Environment(\.lineChartStyle)
    private var lineStyle: LineChartStyle

    @Environment(\.rectangularChartStyle)
    private var rectChartStyle: RectangularChartStyle

    /// Initialize a LineChart view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is an `OrderedDatum`
    ///   - xRange: A range of the `OrderedDatum`'s `X` type, over which to visualize the data. The chart will cover this range, effectively trimming the visible data (if it's smaller).
    ///   - underlay: A view (usually a `ZStack`) to render beneath the chart. Use this to add Decorators without obscuring the chart data
    ///   - overlay: A view (usually a `ZStack`) to render above the chart. Use this to add Decorators stacked on top of the chart data
    public init(data: DataSeries<P>, trimmedTo xRange: Range<P.X>? = nil, underlay: Underlay, overlay: Overlay) {
        self.data = data
        self.xRange = xRange?.mapBounds { $0.dataSeriesValue }
        self.underlay = underlay
        self.overlay = overlay
    }

    /// Initialize a LineChart view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is an `OrderedDatum`
    ///   - xRange: A range of the `OrderedDatum`'s `X` type, over which to visualize the data. The chart will cover this range, effectively trimming the visible data (if it's smaller).
    ///   - underlay: A view (usually a `ZStack`) to render beneath the chart. Use this to add Decorators without obscuring the chart data
    public init(data: DataSeries<P>, trimmedTo xRange: Range<P.X>? = nil, underlay: Underlay) where Overlay == Never {
        self.data = data
        self.xRange = xRange?.mapBounds { $0.dataSeriesValue }
        self.underlay = underlay
        self.overlay = nil
    }

    /// Initialize a LineChart view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is an `OrderedDatum`
    ///   - xRange: A range of the `OrderedDatum`'s `X` type, over which to visualize the data. The chart will cover this range, effectively trimming the visible data (if it's smaller).
    ///   - overlay: A view (usually a `ZStack`) to render above the chart. Use this to add Decorators stacked on top of the chart data
    public init(data: DataSeries<P>, trimmedTo xRange: Range<P.X>? = nil, overlay: Overlay) where Underlay == Never {
        self.data = data
        self.xRange = xRange?.mapBounds { $0.dataSeriesValue }
        self.underlay = nil
        self.overlay = overlay
    }

    /// Initialize a LineChart view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is an `OrderedDatum`
    ///   - xRange: A range of the `OrderedDatum`'s `X` type, over which to visualize the data. The chart will cover this range, effectively trimming the visible data (if it's smaller).
    public init(data: DataSeries<P>, trimmedTo xRange: Range<P.X>? = nil) where Underlay == Never, Overlay == Never {
        self.data = data
        self.xRange = xRange?.mapBounds { $0.dataSeriesValue }
        self.underlay = nil
        self.overlay = nil
    }

    public var body: some View {
        GeometryReader { geometry in
            LinearChartLayoutComposer(data: data, geometry: geometry, xRange: xRange) {
                if let grid = rectChartStyle.yAxisGrid {
                    YAxisGridView(grid: grid)
                }
                if let grid = rectChartStyle.xAxisGrid {
                    XAxisGridView(grid: grid)
                }
                if let underlay = underlay {
                    underlay
                }

                if let edgeColor = lineStyle.lineEdge {
                    Line(width: lineStyle.lineWidth + lineStyle.lineEdgeWidth * 2)
                        .foregroundColor(edgeColor)
                }

                Line(width: lineStyle.lineWidth)
                    .foregroundColor(lineStyle.color)

                if let overlay = overlay {
                    overlay
                }
            }
            .drawingGroup()
        }
        .animation(nil)
    }

}

struct LineChart_Previews: PreviewProvider {

    static var temperatureData: DataSeries<TimeSeriesDatum<Temperature>> {
        dataSeries(for: timeTemp)
    }

    static var previews: some View {
        VStack {
            Spacer()
            LineChart(data: sampleTimeSeries, trimmedTo: .previousWeek, underlay: ZStack {
                PointHighlight(appliesTo: .each(sampleTimeSeries.allY { $0 > 50 }))
                    .chartPointHighlight(stroke: .purple)
                    .chartPointHighlight(strokeWidth: 1)
                    .chartPointHighlight(fill: nil)
                    .chartPointHighlight(radius: 10)
            }, overlay: ZStack {
                PointHighlight(appliesTo: .all)
                PointHighlight(appliesTo: .last)
                    .chartPointHighlight(fill: .red)
                    .chartPointHighlight(radius: 6)
                PointHighlight(appliesTo: .first)
                    .chartPointHighlight(fill: .orange)
                    .chartPointHighlight(radius: 6)
            })
            .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
            .rectChart(yAxisGrid: YAxisGrid(origin: 0, spacing: 10))
            .chartPointHighlight(radius: 5)
            .lineChart(lineEdgeColor: .white)
            .lineChart(lineEdgeWidth: 1)
            .chartInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .frame(height: 120)
            .border(Color.gray)
            Spacer()
            LineChart(data: sampleShortTimeSeries, trimmedTo: .previousWeek, underlay: ZStack {
                XAxisRange(Date().dayStart.dayBefore...Date().dayStart)
                    .rectChartRange(stroke: .blue)
                YAxisRange(...0)
                    .rectChartRange(stroke: .blue)
                YAxisRange(10...20)
                    .rectChartRange(stroke: .blue)
                YAxisRange(30...)
                    .rectChartRange(stroke: .blue)
                XAxisMarker(.axisTic(length: 5), appliesTo: .all)
                    .chartPointHighlight(strokeWidth: 3)
                YAxisMarker(.axisTic(length: 5), appliesTo: .all)
                    .chartPointHighlight(strokeWidth: 3)
            }, overlay: ZStack {
                PointHighlight(appliesTo: .all)
                PointHighlight(appliesTo: .first)
                    .chartPointHighlight(fill: .green)
                    .chartPointHighlight(radius: 8)
                PointHighlight(appliesTo: .last)
                    .chartPointHighlight(radius: 8)
            })
            .frame(height: 150)
            .border(Color.gray)
            .lineChart(lineEdgeColor: .white)
            .lineChart(lineEdgeWidth: 1)
            .chartInsets(.all, 20)
            .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
            .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
            Spacer()
            LineChart(data: temperatureData, underlay: ZStack {
                YAxisRange(...tooCold)
                    .rectChartRange(fill: Color.blue.opacity(0.2))
                    .rectChartRange(stroke: .blue)

                YAxisRange(tooHot...)
                    .rectChartRange(fill: Color.orange.opacity(0.2))
                    .rectChartRange(stroke: .orange)
            }, overlay: ZStack {
                PointHighlight(appliesTo: .all)
                PointHighlight(appliesTo: temperatureData.allY(where: { (tooCold...tooHot).contains($0) }))
                    .chartPointHighlight(radius: 8)
                    .chartPointHighlight(fill: nil)
                    .chartPointHighlight(stroke: .green)
                    .chartPointHighlight(strokeWidth: 2)
            })
            .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
            .rectChart(yAxisGrid: YAxisGrid(spacing: Temperature(celsius: 10)))
            .chartInsets(.all, 20)
            .frame(height: 150)
            Spacer()
        }
        .padding(.all)
        .lineChart(lineWidth: 3)
    }
}

