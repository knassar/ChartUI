//
//  PieChart.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Chart a series of categorized values as radial "pie" wedges
public struct PieChart<Underlay: View, Overlay: View>: View {

    private var data: AnyCategorizedDataSeries

    private var underlay: Underlay?

    private var overlay: Overlay?

    /// Initialize a `PieChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    ///   - underlay: A view (usually a `ZStack`) to render beneath the chart. Use this to add Decorators without obscuring the chart data
    ///   - overlay: A view (usually a `ZStack`) to render above the chart. Use this to add Decorators stacked on top of the chart data
    public init(data: AnyCategorizedDataSeries, underlay: Underlay, overlay: Overlay) {
        self.data = data
        self.underlay = underlay
        self.overlay = overlay
    }

    /// Initialize a `PieChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    ///   - underlay: A view (usually a `ZStack`) to render beneath the chart. Use this to add Decorators without obscuring the chart data
    public init(data: AnyCategorizedDataSeries, underlay: Underlay) where Overlay == Never {
        self.data = data
        self.underlay = underlay
        self.overlay = nil
    }

    /// Initialize a `PieChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    ///   - overlay: A view (usually a `ZStack`) to render above the chart. Use this to add Decorators stacked on top of the chart data
    public init(data: AnyCategorizedDataSeries, overlay: Overlay) where Underlay == Never {
        self.data = data
        self.underlay = nil
        self.overlay = overlay
    }

    /// Initialize a `PieChart` view
    /// - Parameters:
    ///   - data: A `DataSeries` whose data type is a `CategorizedDatum`
    public init(data: AnyCategorizedDataSeries) where Underlay == Never, Overlay == Never {
        self.data = data
        self.underlay = nil
        self.overlay = nil
    }

    public var body: some View {
        RadialChart(data: data, sectorShape: WedgeSector.self, underlay: underlay, overlay: overlay)
    }

}

struct PieChart_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {
        LibraryItem(
            PieChart(data: sampleCalendarData),
            category: .other
            )
    }

}

struct PieChart_Previews: PreviewProvider {

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
                Text("PieChart with a Default Legend")
                PieChart(data: dataToggle ? sampleCalendarData : sampleCalendarData2)
                    .chartInsets(.trailing, 5)
                    .chartInsets(.leading, 100)
                    .chartSegments(strokeWidth: 1)
                    .chartLegend(style: DefaultLegendStyle(nameMapper: sampleCalendarDataNameMapper))
                Spacer()
                Text("PieChart with an Inline Legend")
                PieChart(data: dataToggle ? sampleCalendarData : sampleCalendarData2)
                    .chartInsets(.all, 5)
                    .chartSegments(strokeWidth: 1)
                    .radialChart(projection: 20, for: sampleCalendarData.data[8].id)
                    .radialChart(outerRadius: .proportional)
                    .chartLegend(style: InlineLegendStyle())
                Spacer()
                Button(action: { dataToggle.toggle() }, label: {
                    Text("Change Data")
                })
            }
            .padding(.all)
        }

    }

}

