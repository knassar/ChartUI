//
//  XAxisMarker.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Highlights specified points in a LineChart with the designated `PointAxisMarker`
public struct XAxisMarker: PointDecorator {

    public var appliesTo: PointApplication
    private var marker: PointAxisMarker

    @Environment(\.linearChartLayout)
    public var layout: LinearChartLayout

    @Environment(\.pointHighlightStyle)
    private var style: PointHighlightStyle

    /// Initialize the decorator
    /// - Parameter appliesTo: specifies the points which are to be highlighted
    public init(_ marker: PointAxisMarker, appliesTo: PointApplication) {
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
        var path = Path()
        self.decoratedPoints.forEach { point in
            path.move(to: CGPoint(x: point.x, y: layout.localFrame.maxY))
            path.addLine(to: CGPoint(x: point.x, y: markerMapY(point.y)))
        }
        return path
            .strokedPath(StrokeStyle(lineWidth: style.strokeWidth, lineCap: lineCap))
            .foregroundColor(style.stroke)
    }

    private var markerMapY: (CGFloat) -> CGFloat {
        switch marker {
        case let .axisTic(length):
            return { _ in layout.localFrame.maxY - length }
        case let .toPoint(extending):
            return { $0 + extending }
        case .thruRange:
            return { _ in 0 }
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

struct XAxisMarker_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {

        LibraryItem(XAxisMarker(.thruRange, appliesTo: .all),
                    title: "X-Axis Marker Decorator",
                    category: .other)

    }

}

struct XAxisMarker_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: sampleTimeSeries, trimmedTo: .previousWeek, underlay: ZStack {
            XAxisMarker(.axisTic(), appliesTo: .all)
            XAxisMarker(.toPoint(extending: 5), appliesTo: .last)
            XAxisMarker(.toPoint(), appliesTo: .each(sampleTimeSeries.allY { $0 > 80 }))
                .chartPointHighlight(strokeWidth: 10)
                .chartPointHighlight(stroke: Color(red: 0, green: 1.0, blue: 1.0).opacity(0.25))
        })
            .frame(width: 300, height: 150)
    }
}
