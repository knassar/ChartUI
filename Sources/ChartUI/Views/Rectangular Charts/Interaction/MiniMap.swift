//
//  MiniMap.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/23/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/**
 An interactive mini-map of the entire range of the associated data of a "master" `LineChart`, with a "scroll thumb" which can control the visible portion of the main chart.

 The `MiniMap` view works in conjunction with the `.lineChart(scroll:)` interaction modifier and the `LineChart` `trimmedTo:` initialization argument to produce a second line chart over the same data, but with the visible range exppressed with a "thumb" highlight. The scroll "thumb" can be dragged over the range of the `MiniMap`, scrolling the main chart to the same visible range, even if direct scrolling is disabled on the main chart with `.lineChart(scrollEnabled: false)`. In addition, tapping the `MiniMap`along its range will move the thumb and scroll the main chart to the tapped position.

 Use the `MiniMap` interactive view to provide auxiliary navigation for a large `LineChart` with a `.lineChart(scroll:)` modifier and trimmed to a visible range smaller than the overall data.

 To set up an axuiliary between a "MiniMap" and a main `LineChart`, the two views must share a common ancestor. This ancestor view should own a `@State` or other data binding to both the X-range and scroll-offset used by the main chart.

 The MiniMap chart will display the entire range of the data set.

**Note:** `MiniMap` wraps a `LineChart` view and passes its `underlay` and `overlay` arguments through directly to the internal chart. It can therefore be customized with the same collection of decorators and modifiers as any other `LineChart`.

*/
public struct MiniMap<P: OrderedDatum, Underlay: View, Overlay: View>: View {

    /// The data to display, which should be the same DataSeries displayed by the main chart.
    var data: DataSeries<P>

    /// The X-range used in the main chart.
    var xRange: Range<P.X>

    @Binding
    /// A binding to the same `scrollOffset` value used in the main chart.
    var scrollOffset: CGFloat

    var underlay: Underlay?

    var overlay: Overlay?

    /// Initialize a `MiniMap` view with the supplied data & range, scroll binding, and under- and overlays.
    ///
    /// The scroll thumb will always be placed in the top-most overlay position (highest Z-index).
    ///
    /// - Parameters:
    ///   - data: The `DataSeries` used in the main chart, whose data type is an `OrderedDatum`
    ///   - xRange: The xRange used by the main chart.
    ///   - scrollOffset: The scroll offset binding associated with the main chart.
    ///   - underlay: A view (usually a `ZStack`) to render beneath the `MiniMap`. Use this to add Decorators without obscuring the chart data
    ///   - overlay: A view (usually a `ZStack`) to render above the `MiniMap`, but below the scroll thumb. Use this to add Decorators stacked on top of the chart data
    public init(data: DataSeries<P>, xRange: Range<P.X>, scrollOffset: Binding<CGFloat>, underlay: Underlay, overlay: Overlay) {
        self.data = data
        self.xRange = xRange
        self._scrollOffset = scrollOffset
        self.underlay = underlay
        self.overlay = overlay
    }

    /// Initialize a `MiniMap` view with the supplied data & range, scroll binding, and underlays.
    ///
    /// - Parameters:
    ///   - data: The `DataSeries` used in the main chart, whose data type is an `OrderedDatum`
    ///   - xRange: The xRange used by the main chart.
    ///   - scrollOffset: The scroll offset binding associated with the main chart.
    ///   - underlay: A view (usually a `ZStack`) to render beneath the `MiniMap`. Use this to add Decorators without obscuring the chart data
    public init(data: DataSeries<P>, xRange: Range<P.X>, scrollOffset: Binding<CGFloat>, underlay: Underlay) where Overlay == Never {
        self.data = data
        self.xRange = xRange
        self._scrollOffset = scrollOffset
        self.underlay = underlay
        self.overlay = nil
    }

    /// Initialize a `MiniMap` view with the supplied data & range, scroll binding, and overlays.
    ///
    /// The scroll thumb will always be placed in the top-most overlay position (highest Z-index).
    ///
    /// - Parameters:
    ///   - data: The `DataSeries` used in the main chart, whose data type is an `OrderedDatum`
    ///   - xRange: The xRange used by the main chart.
    ///   - scrollOffset: The scroll offset binding associated with the main chart.
    ///   - overlay: A view (usually a `ZStack`) to render above the `MiniMap`, but below the scroll thumb. Use this to add Decorators stacked on top of the chart data
    public init(data: DataSeries<P>, xRange: Range<P.X>, scrollOffset: Binding<CGFloat>, overlay: Overlay) where Underlay == Never {
        self.data = data
        self.xRange = xRange
        self._scrollOffset = scrollOffset
        self.underlay = nil
        self.overlay = overlay
    }

    /// Initialize a `MiniMap` view with the supplied data & range, scroll binding.
    ///
    /// - Parameters:
    ///   - data: The `DataSeries` used in the main chart, whose data type is an `OrderedDatum`
    ///   - xRange: The xRange used by the main chart.
    ///   - scrollOffset: The scroll offset binding associated with the main chart.
    public init(data: DataSeries<P>, xRange: Range<P.X>, scrollOffset: Binding<CGFloat>) where Underlay == Never, Overlay == Never {
        self.data = data
        self.xRange = xRange
        self._scrollOffset = scrollOffset
        self.underlay = nil
        self.overlay = nil
    }


    public var body: some View {
        LineChart(data: data, underlay: underlay, overlay: ZStack {
            if let overlay = overlay {
                overlay
            }
            MapInteraction(scrollOffset: $scrollOffset, range: xRange)
        })
    }

    private struct MapInteraction: View {

        @Binding
        var scrollOffset: CGFloat

        var range: Range<P.X>

        @State
        private var offsetAtGestureStart = CGFloat.nan

        @Environment(\.rectangularChartLayout)
        private var rectLayout: RectangularChartLayout

        @Environment(\.lineChartLayout)
        private var lineLayout: LineChartLayout

        private var maxScrollOffset: CGFloat {
            lineLayout.xInLayout(fromDataX: max(lineLayout.absoluteDataBounds.end, range.upperBound.dataSeriesValue)) - lineLayout.xInLayout(fromDataX: min(lineLayout.absoluteDataBounds.start, range.lowerBound.dataSeriesValue)) - thumbWidth
        }

        private var thumbWidth: CGFloat {
            lineLayout.xInLayout(fromDataX: range.upperBound.dataSeriesValue) - lineLayout.xInLayout(fromDataX: range.lowerBound.dataSeriesValue)
        }

        private var thumbMinX: CGFloat {
            lineLayout.xInLayout(fromDataX: range.lowerBound.dataSeriesValue) - (maxScrollOffset - scrollOffset * maxScrollOffset)
        }

        var body: some View {
            ZStack {
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.001))
                    .gesture(tap)

                DefaultThumb(x: thumbMinX, size: CGSize(width: thumbWidth, height: rectLayout.localFrame.height))
                    .gesture(drag)
            }
        }

        private var drag: some Gesture {
            DragGesture()
                .onChanged { value in
                    if offsetAtGestureStart.isNaN {
                        offsetAtGestureStart = scrollOffset
                    }
                    scrollOffset = offsetAtGestureStart + value.translation.width / maxScrollOffset
                }
                .onEnded { _ in
                    scrollOffset = min(max(0, scrollOffset), 1)
                    offsetAtGestureStart = .nan
                }
        }

        private var tap: some Gesture {
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    let offset = (value.startLocation.x - thumbWidth / 2) / maxScrollOffset
                    scrollOffset = min(max(0, offset), 1)
                    offsetAtGestureStart = .nan
                }
        }

    }

    private struct DefaultThumb: View {

        var x: CGFloat
        var size: CGSize

        var body: some View {
            LineSegment(start: CGPoint(x: x, y: 0),
                        end: CGPoint(x: x, y: size.height))
                .strokeBorder(Color.accentColor, lineWidth: 0.5)

            RectangularRange(CGRect(x: x, y: 0, width: size.width, height: size.height))
                .foregroundColor(Color.accentColor.opacity(0.2))

            LineSegment(start: CGPoint(x: x + size.width, y: 0),
                        end: CGPoint(x: x + size.width, y: size.height))
                .strokeBorder(Color.accentColor, lineWidth: 0.5)
        }

    }

}

// TODO: MiniMap deserves a LibraryContentProvider, but there's no way to make one without concrete values in all init arguments, which is difficult for this view which requires data, X-range, and offset binding.

struct MiniMap_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            Text("MiniMap")
                .padding(.top)
            AnimatingPreview()
        }
    }

    struct AnimatingPreview: View {

        @State
        var xRange: Range<Date> = .previousWeek

        @State
        var scroll: CGFloat = 1

        @State
        var scrollEnabled = true

        @State
        var shortData = true

        var temperatureData: DataSeries<TimeSeriesDatum<Temperature>> {
            dataSeries(for: timeTemp)
        }

        var data: DataSeries<TimeSeriesDatum<Double>> {
            shortData
                ? DataSeries(data: Array(sampleTimeSeries.data.suffix(18)))
                : sampleTimeSeries
        }

        var body: some View {
            VStack {
                HStack {
                    Picker("Range", selection: $xRange) {
                        Text("1 Y").tag(Range<Date>.previousYear)
                        Text("3 M").tag(
                            Calendar.current.date(byAdding: .month, value: -3, to: .today)!.dayStart..<Date.today.dayAfter
                        )
                        Text("1 M").tag(Range<Date>.previousMonth)
                        Text("1 W").tag(Range<Date>.previousWeek)
                    }
                    .padding(.vertical, 8)
                    .pickerStyle(SegmentedPickerStyle())
                    toggle("Short Data", $shortData)
                }
                MiniMap(data: data, xRange: xRange, scrollOffset: $scroll)
                    .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: TimeInterval.days(7)))
                    .chartInsets(.vertical, 8)
                    .frame(height: 24)
                    .border(Color.gray)

                LineChart(data: data, trimmedTo: xRange, underlay: ZStack {
                    PointHighlight(appliesTo: .each(sampleTimeSeries.allY { $0 > 50 }))
                        .chartPointHighlight(stroke: .purple)
                        .chartPointHighlight(strokeWidth: 1)
                        .chartPointHighlight(fill: nil)
                        .chartPointHighlight(radius: 10)
                    XAxisRange((Date.today.dayBefore.dayBefore)..<Date.today)
                        .rectChartRange(fill: Color.blue.opacity(0.2))
                        .rectChartRange(stroke: .blue)
                    YAxisRange(20...50)
                        .rectChartRange(fill: Color.purple.opacity(0.2))
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
                .lineChart(lineColor: .red)
                .rectChart(xOriginMark: .tic(length: 5, width: 2))
                .rectChart(yOriginMark: .tic(length: 1, width: 2))
                .rectChart(originColor: .purple)
                .lineChart(scrollOffset: $scroll, enabled: scrollEnabled)
                .chartInsets(.vertical, 20)
                .chartInsets(.all, 8)
                .frame(height: 160)
                .border(Color.gray)

                HStack {
                    Text("scrolled to: \(scroll)")
                        .font(.caption)
                    Spacer()
                    toggle("Manual Scroll", $scrollEnabled)
                }

                HStack {
                    Text("Toggle \"Manual Scroll\" to enable/disable the scroll gestures on the main chart. Note that scrolling using the MiniMap is preserved even when direct scrolling is disabled.")
                        .font(.caption)
                }
                .padding(.top)

                Spacer()
            }
            .padding(.all)
            .lineChart(lineWidth: 2)
            .accentColor(.blue)
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
