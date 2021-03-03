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
            LineChartLayoutComposer(data: data, geometry: geometry, xRange: xRange,
                                    underlay: FrameUnderlay(underlay: underlay),
                                    content: FrameContent(overlay: overlay))
                    .animation(.default)
            .drawingGroup()
        }
    }

    private struct FrameUnderlay: View {

        var underlay: Underlay?

        @Environment(\.lineChartSegment)
        var segment: LineChartLayout.Segment

        @Environment(\.rectangularChartLayout)
        var rectLayout: RectangularChartLayout

        @Environment(\.rectangularChartStyle)
        var rectChartStyle: RectangularChartStyle

        @Environment(\.lineChartStyle)
        var lineStyle: LineChartStyle

        var body: some View {
            ZStack {
                if let grid = rectChartStyle.yAxisGrid {
                    YAxisGridView(grid: grid, segment: segment)
                }
                if let grid = rectChartStyle.xAxisGrid {
                    XAxisGridView(grid: grid, segment: segment)
                }
                if let underlay = underlay {
                    underlay
                }

                if let edgeColor = lineStyle.lineEdge {
                    Line(segment: segment, width: lineStyle.lineWidth + lineStyle.lineEdgeWidth * 2)
                        .foregroundColor(edgeColor)
                }
            }

        }
    }

    private struct FrameContent: View {

        var overlay: Overlay?

        @Environment(\.lineChartSegment)
        var segment: LineChartLayout.Segment

        @Environment(\.rectangularChartLayout)
        var rectLayout: RectangularChartLayout

        @Environment(\.rectangularChartStyle)
        var rectChartStyle: RectangularChartStyle

        @Environment(\.lineChartStyle)
        var lineStyle: LineChartStyle

        var body: some View {
            ZStack {
                if case let .color(fillColor) = lineStyle.lineFill {
                    Line(segment: segment, width: lineStyle.lineWidth, fill: true)
                        .fill()
                        .foregroundColor(fillColor)
                } else if case let .gradient(fill) = lineStyle.lineFill {
                    Line(segment: segment, width: lineStyle.lineWidth, fill: true)
                        .fill(fill)
                }

                Line(segment: segment, width: lineStyle.lineWidth)
                    .foregroundColor(lineStyle.color)

                if let overlay = overlay {
                    overlay
                }
            }
        }
    }

}

// MARK: - Library Content

struct LineChart_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {
        LibraryItem(
            LineChart(data: sampleTimeSeries,
                      underlay: ZStack { /* add decorators here */ },
                      overlay: ZStack { /* add decorators here */ }),
            category: .other
            )
    }

}

// MARK: - Previews

struct LineChart_Previews: PreviewProvider {

    static var temperatureData: DataSeries<TimeSeriesDatum<Temperature>> {
        dataSeries(for: timeTemp)
    }

    static var previews: some View {
        VStack {
            Text("Sample Line Charts")
                .padding(.top)
            AnimatingPreview()
        }
    }

    struct AnimatingPreview: View {

        @State
        var xRange: Range<Date> = .previousWeek

        @State
        var origin = true

        @State
        var pointHighlights = true

        @State
        var ranges = true

        @State
        var marks = false

        @State
        var insets: CGFloat = 0.2

        @State
        var scrollOn: Bool = true

        @State
        var scrollOffset: CGFloat = 1

        @State
        var tapped: Bool = false

        var body: some View {
            VStack {
                controlPanel
                Spacer()
                HStack {
                    Text("scrolled to: \(scrollOffset)")
                        .font(.caption)
                    Spacer()
                }
                LineChart(data: sampleTimeSeries, trimmedTo: xRange, underlay: ZStack {
                    if pointHighlights {
                        PointHighlight(appliesTo: .each(sampleTimeSeries.allY { $0 > 50 }))
                            .chartPointHighlight(stroke: .purple)
                            .chartPointHighlight(strokeWidth: 1)
                            .chartPointHighlight(fill: nil)
                            .chartPointHighlight(radius: 10)
                    }
                    if ranges {
                        XAxisRange((Date.today.dayBefore.dayBefore)..<Date.today)
                            .rectChartRange(fill: Color.blue.opacity(0.2))
                            .rectChartRange(stroke: .blue)
                        YAxisRange(20...50)
                            .rectChartRange(fill: Color.purple.opacity(0.2))
                    }
                    if marks {
                        XAxisMarker(.toPoint(), appliesTo: .all)
                            .chartPointHighlight(stroke: .gray)
                            .chartPointHighlight(strokeWidth: 1)
                        YAxisMarker(.toPoint(), appliesTo: .all)
                            .chartPointHighlight(stroke: .gray)
                            .chartPointHighlight(strokeWidth: 1)
                    }
                }, overlay: ZStack {
                    if pointHighlights {
                        PointHighlight(appliesTo: .all)
                        PointHighlight(appliesTo: .last)
                            .chartPointHighlight(fill: .red)
                            .chartPointHighlight(radius: 6)
                        PointHighlight(appliesTo: .first)
                            .chartPointHighlight(fill: .orange)
                            .chartPointHighlight(radius: 6)
                    }
                    if origin {
                        Origin()
                    }
                })
                .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
                .rectChart(yAxisGrid: YAxisGrid(origin: 0, spacing: 10))
                .chartPointHighlight(radius: 5)
                .lineChart(lineEdgeColor: .white)
                .lineChart(lineEdgeWidth: 1)
                .lineChart(lineColor: .red)
                .rectChart(xOriginMark: .tic(length: 5, width: 2))
                .rectChart(yOriginMark: .tic(length: 1, width: 2))
                .rectChart(originColor: .purple)
                .lineChart(scrollOffset: $scrollOffset, enabled: scrollOn)
                .chartInsets(.all, insets * 50)
                .frame(height: 120)
                .border(Color.gray)

                LineChart(data: sampleShortTimeSeries, underlay: ZStack {
                    if ranges {
                        XAxisRange(Date().dayStart.dayBefore...Date().dayStart)
                            .rectChartRange(stroke: .blue)
                        YAxisRange(...0)
                            .rectChartRange(stroke: .blue)
                        YAxisRange(10...20)
                            .rectChartRange(stroke: .blue)
                        YAxisRange(30...)
                            .rectChartRange(stroke: .blue)
                    }
                    if marks {
                        XAxisMarker(.axisTic(length: 5), appliesTo: .all)
                            .chartPointHighlight(strokeWidth: 3)
                        YAxisMarker(.axisTic(length: 5), appliesTo: .all)
                            .chartPointHighlight(strokeWidth: 3)
                    }
                }, overlay: ZStack {
                    if pointHighlights {
                        PointHighlight(appliesTo: .all)
                        PointHighlight(appliesTo: .first)
                            .chartPointHighlight(fill: .green)
                            .chartPointHighlight(radius: 8)
                        PointHighlight(appliesTo: .last)
                            .chartPointHighlight(radius: 8)
                    }
                    if origin {
                        Origin()
                    }
                })
                .frame(height: 180)
                .border(Color.gray)
                .lineChart(lineEdgeColor: .white)
                .lineChart(lineEdgeWidth: 1)
                .chartInsets(.all, 10)
                .chartInsets(.horizontal, 40)
                .chartInsets(.top, 80)
                .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
                .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
                .rectChart(originMark: .line(width: 2))
                .rectChart(originColor: .purple)
                .sheet(isPresented: $tapped, content: {
                    Text("Tapped")
                })
                .onTapGesture {
                    tapped.toggle()
                }

                LineChart(data: temperatureData, trimmedTo: xRange, underlay: ZStack {
                    if ranges {
                        YAxisRange(...tooCold)
                            .rectChartRange(fill: Color.blue.opacity(0.2))
                            .rectChartRange(stroke: .blue)

                        YAxisRange(tooHot...)
                            .rectChartRange(fill: Color.orange.opacity(0.2))
                            .rectChartRange(stroke: .orange)
                    }
                }, overlay: ZStack {
                    if pointHighlights {
                        PointHighlight(appliesTo: .all)
                        PointHighlight(appliesTo: temperatureData.allY(where: { (tooCold...tooHot).contains($0) }))
                            .chartPointHighlight(radius: 5)
                            .chartPointHighlight(fill: .green)

                        PointHighlight(appliesTo: temperatureData.allY(where: { (tooCold...tooHot).contains($0) }))
                            .chartPointHighlight(radius: 8)
                            .chartPointHighlight(fill: nil)
                            .chartPointHighlight(stroke: .green)
                            .chartPointHighlight(strokeWidth: 2)
                    }
                })
                .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(1)))
                .rectChart(yAxisGrid: YAxisGrid(spacing: Temperature(celsius: 10)))
                .chartInsets(.all, insets * 50)
                .lineChart(scrollEnabled: scrollOn)
                .lineChart(fill: Gradient(colors: [.white, .blue]))
                .frame(height: 150)
                .border(Color.gray)
            }
            .padding(.all)
            .lineChart(lineWidth: 2)
        }

        var controlPanel: some View {
            VStack {
                Picker("Range", selection: $xRange) {
                    Text("Year").tag(Range<Date>.previousYear)
                    Text("3 Months").tag(
                        Calendar.current.date(byAdding: .month, value: -3, to: .today)!.dayStart..<Date.today.dayAfter
                    )
                    Text("Month").tag(Range<Date>.previousMonth)
                    Text("Week").tag(Range<Date>.previousWeek)
                }
                .padding(.vertical, 8)
                .pickerStyle(SegmentedPickerStyle())

                HStack {
                    Text("Insets: ").font(.caption)
                    Slider(value: $insets, in: 0...1)
                }

                HStack {
                    toggle("Origin", $origin)
                    Spacer()
                    toggle("Ranges", $ranges)
                    Spacer()
                    toggle("Points", $pointHighlights)
                    Spacer()
                    toggle("Marks", $marks)
                    Spacer()
                    toggle("Scroll", $scrollOn)
                }
            }
        }

        func toggle(_ name: String, _ value: Binding<Bool>) -> some View {
            Button(action: { value.wrappedValue.toggle() }) {
                if value.wrappedValue {
                    Color.accentColor
                        .cornerRadius(2)
                        .frame(width: 10, height: 10)
                } else {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.accentColor, lineWidth: 1)
                        .frame(width: 10, height: 10)
                }
                Text(name)
                    .font(.caption)
            }
        }
    }
}

