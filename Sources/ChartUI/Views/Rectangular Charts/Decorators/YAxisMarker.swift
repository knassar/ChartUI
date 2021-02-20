//
//  YAxisMarker.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Highlights specified points in a LineChart with the designated `PointAxisMarker`
public struct YAxisMarker: PointDecorator {

    private var marker: PointAxisMarker
    public var appliesTo: PointApplication

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
            path.move(to: CGPoint(x: 0, y: point.y))
            path.addLine(to: CGPoint(x: markerMapX(point.x), y: point.y))
        }
        return path
            .strokedPath(StrokeStyle(lineWidth: style.strokeWidth, lineCap: lineCap))
            .foregroundColor(style.stroke)
    }

    private var markerMapX: (CGFloat) -> CGFloat {
        switch marker {
        case let .axisTic(length):
            return { _ in length }
        case let .toPoint(extending):
            return { $0 + extending }
        case .thruRange:
            return { _ in layout.localFrame.maxX }
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
