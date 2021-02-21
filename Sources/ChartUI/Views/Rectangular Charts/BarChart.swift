//
//  BarChart.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Chart a series of categorized values as vertical bars
struct BarChart<P: CategorizedDatum, Underlay: View, Overlay: View>: View {

    private var data: DataSeries<P>

    private var underlay: Underlay?

    private var overlay: Overlay?

    @Environment(\.lineChartStyle)
    private var lineStyle: LineChartStyle

    @Environment(\.rectangularChartStyle)
    private var rectChartStyle: RectangularChartStyle

    @Environment(\.categorizedDataStyle)
    private var categorizedData: CategorizedDataStyle

    /// Initialize a `BarChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    ///   - underlay: A view (usually a `ZStack`) to render beneath the chart. Use this to add Decorators without obscuring the chart data
    ///   - overlay: A view (usually a `ZStack`) to render above the chart. Use this to add Decorators stacked on top of the chart data
    public init(data: DataSeries<P>, underlay: Underlay, overlay: Overlay) {
        self.data = data
        self.underlay = underlay
        self.overlay = overlay
    }

    /// Initialize a `BarChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    ///   - underlay: A view (usually a `ZStack`) to render beneath the chart. Use this to add Decorators without obscuring the chart data
    public init(data: DataSeries<P>, underlay: Underlay) where Overlay == Never {
        self.data = data
        self.underlay = underlay
        self.overlay = nil
    }

    /// Initialize a `BarChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    ///   - overlay: A view (usually a `ZStack`) to render above the chart. Use this to add Decorators stacked on top of the chart data
    public init(data: DataSeries<P>, overlay: Overlay) where Underlay == Never {
        self.data = data
        self.underlay = nil
        self.overlay = overlay
    }

    /// Initialize a `BarChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    public init(data: DataSeries<P>) where Underlay == Never, Overlay == Never {
        self.data = data
        self.underlay = nil
        self.overlay = nil
    }

    public var body: some View {
        GeometryReader { geometry in
            LinearChartLayoutComposer(data: data, geometry: geometry) {
                if let grid = rectChartStyle.yAxisGrid {
                    YAxisGridView(grid: grid)
                        .animation(.default)
                }
                if let underlay = underlay {
                    underlay
                }
                ForEach(zOrderedDatums) {
                    Bar(datum: $0, shape: RectBar.self)
                        .animation(.default)
                }
                if let overlay = overlay {
                    overlay
                }
                RectangularLegend()
            }
            .drawingGroup()
        }
    }

    private var zOrderedDatums: [AnyCategorizedDatum] {
        data.categorizedData.sorted { categorizedData.zIndex(for: $0) < categorizedData.zIndex(for: $1) }
    }

}

struct BarChart_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {
        LibraryItem(
            BarChart(data: sampleCalendarData,
                      underlay: ZStack { /* add decorators here */ },
                      overlay: ZStack { /* add decorators here */ }),
            category: .other
            )
    }

}

struct BarChart_Previews: PreviewProvider {

    static var toggle = true

    static var previews: some View {
        AnimatingPreview()
    }

    struct AnimatingPreview: View {

        @State
        var dataToggle = true

        var body: some View {
            VStack {
                Spacer()
                Text("BarChart with a Default Legend")
                BarChart(data: dataToggle ? sampleCalendarData : sampleCalendarData2, underlay: ZStack {
                    YAxisRange(10...20)
                        .rectChartRange(stroke: .blue)
                })
                    .chartInsets(.leading, 80)
                    .chartInsets(.top, 50)
                    .chartInsets(.all, 20)
                    .chartSegments(strokeColor: .black)
                    .chartLegend(style: DefaultLegendStyle(position: .topLeading))
                    .frame(height: 280)
                    .border(Color.gray)
                    .barChart(width: 8)
                    .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
                Spacer()
                Text("BarChart with an Inline Legend")
                BarChart(data: dataToggle ? sampleCalendarData : sampleCalendarData2, underlay: ZStack {
                    YAxisRange(10...20)
                        .rectChartRange(stroke: .blue)
                })
                    .chartInsets(.all, 20)
                    .chartSegments(strokeColor: .black)
                    .chartLegend(style: InlineLegendStyle())
                    .frame(height: 200)
                    .border(Color.gray)
                    .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
                Spacer()
                Button(action: { $dataToggle.wrappedValue.toggle() }, label: {
                    Text("Change Data")
                })
            }
            .padding(.all)
        }

    }

}
