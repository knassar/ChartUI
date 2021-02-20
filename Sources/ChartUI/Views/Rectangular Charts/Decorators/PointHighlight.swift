//
//  PointHighlight.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// Highlights specified points in a LineChart
public struct PointHighlight: PointDecorator {

    public var appliesTo: PointApplication

    @Environment(\.linearChartLayout)
    public var layout: LinearChartLayout

    @Environment(\.pointHighlightStyle)
    private var style: PointHighlightStyle

    /// Initialize the decorator
    /// - Parameter appliesTo: specifies the points which are to be highlighted
    public init(appliesTo: PointApplication) {
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
                path
                    .fill()
                    .foregroundColor(fill)
            }
            if let stroke = style.stroke {
                path
                    .strokedPath(StrokeStyle(lineWidth: style.strokeWidth))
                    .foregroundColor(stroke)
            }
        }
    }

    private var path: Path {
        let rects = self.rects
        guard !rects.isEmpty else { return Path() }
        if let singleRect = rects.first, rects.count == 1 {
            return Path(ellipseIn: singleRect)
        } else {
            var path = Path()
            rects.forEach { path.addEllipse(in: $0) }
            return path
        }
    }

    private var rects: [CGRect] {
        let radius = style.radius
        return decoratedPoints.map { center in
            CGRect(origin: CGPoint(x: center.x - radius, y: center.y - radius),
                   size: CGSize(width: radius * 2, height: radius * 2))
        }
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
