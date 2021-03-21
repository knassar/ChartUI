//
//  PointHighlight.swift
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

/// Highlights specified points in a LineChart
public struct PointHighlight: View {

    public var appliesTo: PointSelection

    @Environment(\.lineChartSegment)
    public var segment: LineChartLayout.Segment

    @Environment(\.pointHighlightStyle)
    private var style: PointHighlightStyle

    /// Initialize the decorator
    /// - Parameter appliesTo: specifies the points which are to be highlighted
    public init(appliesTo: PointSelection) {
        self.appliesTo = appliesTo
    }

    /// Initialize the decorator.
    ///
    /// This method is a convenience shorthand for `.init(appliesTo: .each([AnyDatum]))`
    /// - Parameter appliesTo: specifies the points which are to be highlighted.
    public init(appliesTo: [AnyDatum]) {
        self.appliesTo = .each(appliesTo)
    }

    public var body: some View {
        ZStack {
            if let fill = style.fill {
                Highlight(segment: segment, application: appliesTo, radius: style.radius)
                    .fill()
                    .foregroundColor(fill)
            }
            if let stroke = style.stroke {
                Highlight(segment: segment, application: appliesTo, radius: style.radius, strokeWidth: style.strokeWidth)
                    .foregroundColor(stroke)
            }
        }
    }

    private struct Highlight: InsettableShape {

        var segment: LineChartLayout.Segment
        var application: PointSelection
        var radius: CGFloat
        var strokeWidth: CGFloat?

        var animatableData: LineChartLayout.Segment.AnimatableData {
            get { segment.animatableData }
            set { segment.animatableData = newValue }
        }

        func inset(by amount: CGFloat) -> some InsettableShape {
            self
        }

        func path(in rect: CGRect) -> Path {
            var path: Path
            let rects = self.rects
            guard !rects.isEmpty else { return Path() }
            if let singleRect = rects.first, rects.count == 1 {
                path = Path(ellipseIn: singleRect)
            } else {
                path = Path()
                rects.forEach { path.addEllipse(in: $0) }
            }

            if let strokeWidth = strokeWidth {
                return path.strokedPath(StrokeStyle(lineWidth: strokeWidth))
            } else {
                return path
            }
        }

        private var rects: [CGRect] {
            return segment.pointsToDecorate(in: application).map { center in
                CGRect(origin: CGPoint(x: center.x - radius, y: center.y - radius),
                       size: CGSize(width: radius * 2, height: radius * 2))
            }
        }

    }
}

struct PointHighlight_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {

        LibraryItem(PointHighlight(appliesTo: .all),
                    title: "Point Highlight Decorator",
                    category: .other)

    }

}

struct PointHighlight_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries, trimmedTo: .previousWeek, overlay: ZStack {
            PointHighlight(appliesTo: .all)
                .chartPointHighlight(fill: .green)
            PointHighlight(appliesTo: .each(sampleTimeSeries.allY { $0 > 50 }))
                .chartPointHighlight(stroke: .blue)
                .chartPointHighlight(fill: nil)
                .chartPointHighlight(radius: 8)
            PointHighlight(appliesTo: .last)
                .chartPointHighlight(fill: .red)
        })
        .chartPointHighlight(radius: 5)
        .chartInsets(.all, 20)
        .frame(width: 300, height: 150)
    }
}
