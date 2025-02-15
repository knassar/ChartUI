//
//  BarChart.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2019 HungryMelonStudios LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//      http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

    @Environment(\.isEnabled)
    var isEnabled: Bool

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
            RectangularChartLayoutComposer(data: data, geometry: geometry) {
                if let grid = rectChartStyle.yAxisGrid {
                    YAxisGridView(grid: grid)
                        .animation(.default)
                }
                if let underlay = underlay {
                    underlay
                }
                ForEach(zOrderedDatums) { datum in
                    Bar(datum: datum, shape: RectBar.self)
                        .modifier(if: categorizedData.hasInteraction) {
                            $0.gesture(gesture(for: datum))
                        }
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

    private func gesture(for datum: AnyCategorizedDatum) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard value.startLocation == value.location else { return }
                self.onTouchDown(datum)
            }
            .onEnded { _ in
                self.onTouchUp()
            }
    }

    private func onTouchDown(_ datum: AnyCategorizedDatum) {
        guard isEnabled else { return }
        categorizedData.momentaryTapHandler?(datum)
        categorizedData.tapHandler?(datum)
    }

    private func onTouchUp() {
        guard isEnabled else { return }
        categorizedData.momentaryTapHandler?(nil)
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
        
        @State
        var tappedDatumId: AnyHashable?

        @State
        var interaction = true

        @State
        var tapped = false

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
                .barChart(width: 20, for: tappedDatumId)
                .onChartSegmentTapGesture { datum in
                    tappedDatumId = datum?.id
                }
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
                .chartSegment(strokeWidth: 2, for: tappedDatumId)
                .chartSegment(strokeColor: .accentColor, for: tappedDatumId)
                .frame(height: 200)
                .border(Color.gray)
                .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
                .modifier(if: interaction) {
                    $0.onChartSegmentMomentaryTouchGesture { datum in
                        tappedDatumId = datum?.id
                    }
                }
                .onTapGesture {
                    tapped = true
                }
                .sheet(isPresented: $tapped, content: {
                    Text("Tapped")
                })

                Spacer()
                HStack {
                    Button(action: { dataToggle.toggle() }, label: {
                        Text("Change Data")
                    })
                    Spacer()
                    Button(action: { interaction.toggle() }) {
                        if interaction {
                            Color.accentColor
                                .cornerRadius(2)
                                .frame(width: 10, height: 10)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.accentColor, lineWidth: 1)
                                .frame(width: 10, height: 10)
                        }
                        Text("Interaction")
                            .font(.caption)
                    }
                }
            }
            .padding(.all)
        }

    }
    
}
