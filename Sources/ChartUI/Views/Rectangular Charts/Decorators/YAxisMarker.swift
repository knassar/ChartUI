//
//  YAxisMarker.swift
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

/// Highlights specified points in a LineChart with the designated `PointAxisMarker`
public struct YAxisMarker: View {

    private var marker: PointAxisMarker
    public var appliesTo: PointSelection

    @Environment(\.lineChartSegment)
    public var segment: LineChartLayout.Segment

    @Environment(\.pointHighlightStyle)
    private var style: PointHighlightStyle

    /// Initialize the decorator
    /// - Parameter appliesTo: specifies the points which are to be highlighted
    public init(_ marker: PointAxisMarker, appliesTo: PointSelection) {
        self.marker = marker
        self.appliesTo = appliesTo
    }

    /// Initialize the decorator.
    /// 
    /// This method is a convenience shorthand for `.init(appliesTo: .each([AnyDatum]))`
    /// - Parameter appliesTo: specifies the points which are to be highlighted.
    public init(_ marker: PointAxisMarker, appliesTo: [AnyDatum]) {
        self.marker = marker
        self.appliesTo = .each(appliesTo)
    }

    public var body: some View {
        Mark(segment: segment, application: appliesTo, marker: marker, strokeWidth: style.strokeWidth)
            .foregroundColor(style.stroke)
    }

    private struct Mark: InsettableShape {

        var segment: LineChartLayout.Segment
        var application: PointSelection
        var marker: PointAxisMarker
        var strokeWidth: CGFloat

        @Environment(\.lineChartLayout)
        var lineLayout: LineChartLayout

        var animatableData: LineChartLayout.Segment.AnimatableData {
            get { segment.animatableData }
            set { segment.animatableData = newValue }
        }

        func inset(by amount: CGFloat) -> some InsettableShape {
            self
        }

        func path(in rect: CGRect) -> Path {
            var path = Path()
            segment.pointsToDecorate(in: application).forEach { point in
                path.move(to: CGPoint(x: 0, y: point.y))
                path.addLine(to: CGPoint(x: markerMapX(point.x), y: point.y))
            }
            return path
                .strokedPath(StrokeStyle(lineWidth: strokeWidth, lineCap: lineCap))
        }

        private var markerMapX: (CGFloat) -> CGFloat {
            switch marker {
            case let .axisTic(length):
                return { _ in length }
            case let .toPoint(extending):
                return { $0 + extending }
            case .thruRange:
                return { _ in lineLayout.localFrame.maxX }
            }
        }

        private var lineCap: CGLineCap {
            switch marker {
            case .axisTic, .thruRange:
                return .butt
            case .toPoint:
                return .round
            }
        }

    }

}

struct YAxisMarker_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {

        LibraryItem(YAxisMarker(.thruRange, appliesTo: .all),
                    title: "Y-Axis Marker Decorator",
                    category: .other)

    }

}

struct YAxisMarker_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries, trimmedTo: .previousWeek, underlay: ZStack {
            YAxisMarker(.axisTic(), appliesTo: .all)
            YAxisMarker(.thruRange, appliesTo: .last)
                .chartPointHighlight(strokeWidth: 3)
                .opacity(0.5)
            YAxisMarker(.toPoint(extending: 5), appliesTo: .last)
                .chartPointHighlight(strokeWidth: 10)
                .chartPointHighlight(stroke: Color(red: 0, green: 1.0, blue: 1.0).opacity(0.25))
        })
            .frame(width: 300, height: 150)
    }
}
