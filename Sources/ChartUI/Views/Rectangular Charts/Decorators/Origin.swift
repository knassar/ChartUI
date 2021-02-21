//
//  Origin.swift
//  
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// The style of mark for the origin
public enum OriginMark {

    /// mark the origin with a line of lineWidth `width` all the way through the chart
    case line(width: CGFloat)

    /// mark the origin with a line of lineWidth `width`, in both positive and negative up to `length * gridSpacing`
    case tic(length: CGFloat, width: CGFloat)

    /// mark the origin with a line of lineWidth `width`, in both positive and negative up to `length * gridSpacing`
    case positiveTic(length: CGFloat, width: CGFloat)

    fileprivate var width: CGFloat {
        switch self {
        case let .line(width):
            return width
        case let .tic(_, width):
            return width
        case let .positiveTic(_, width):
            return width
        }
    }

}

/// Renders a specified mark for the X, Y, or both origins in a rectangular chart.
public struct Origin: View {

    @Environment(\.linearChartLayout)
    private var layout: LinearChartLayout

    @Environment(\.rectangularChartStyle)
    private var style: RectangularChartStyle

    public var body: some View {
        if let yMark = style.yOriginMark, yOriginVisible {
            lineSegment(atY: originY, ends: ySegmentEnds(yMark))
                .strokeBorder(style.yOriginColor ?? .black, lineWidth: yMark.width)
        }
        if let xMark = style.xOriginMark, xOriginVisible {
            lineSegment(atX: originX, ends: xSegmentEnds(xMark))
                .strokeBorder(style.xOriginColor ?? .black, lineWidth: xMark.width)
        }
    }

    private func lineSegment(atX x: CGFloat, ends: (CGFloat, CGFloat)) -> LineSegment {
        let x = layout.xInLayout(fromDataX: x)
        return LineSegment(start: CGPoint(x: x, y: ends.0),
                           end: CGPoint(x: x, y: ends.1))
    }

    private func lineSegment(atY y: CGFloat, ends: (CGFloat, CGFloat)) -> LineSegment {
        let y = layout.yInLayout(fromDataY: y)
        return LineSegment(start: CGPoint(x: ends.0, y: y),
                           end: CGPoint(x: ends.1, y: y))
    }

    private func xSegmentEnds(_ mark: OriginMark) -> (CGFloat, CGFloat) {
        switch (mark, yGrid?.gridSpacing) {
        case (.line, _),
             (_, .none):
            return (layout.localFrame.minY, layout.localFrame.maxY)
        case let (.tic(length, _), .some(spacing)):
            let ticLength = length * spacing
            return (layout.yInLayout(fromDataY: originY - ticLength),
                    layout.yInLayout(fromDataY: originY + ticLength))
        case let (.positiveTic(length, _), .some(spacing)):
            let ticLength = length * spacing
            return (layout.yInLayout(fromDataY: originY),
                    layout.yInLayout(fromDataY: originY + ticLength))
        }
    }

    private func ySegmentEnds(_ mark: OriginMark) -> (CGFloat, CGFloat) {
        switch (mark, xGrid?.gridSpacing) {
        case (.line, _),
             (_, .none):
            return (layout.localFrame.minX, layout.localFrame.maxX)
        case let (.tic(length, _), .some(spacing)):
            let ticLength = length * spacing
            return (layout.xInLayout(fromDataX: originX - ticLength),
                    layout.xInLayout(fromDataX: originX + ticLength))
        case let (.positiveTic(length, _), .some(spacing)):
            let ticLength = length * spacing
            return (layout.xInLayout(fromDataX: originX),
                    layout.xInLayout(fromDataX: originX + ticLength))
        }
    }

    private var xGrid: XAxisGrid? {
        style.xAxisGrid
    }

    private var originX: CGFloat {
        guard let xGrid = xGrid else { return layout.origin.x }
        return xGrid.originIsAbsolute
            ? xGrid.origin
            : layout.origin.x + xGrid.origin
    }

    private var xOriginVisible: Bool {
        layout.isVisible(x: originX)
    }

    private var yGrid: YAxisGrid? {
        style.yAxisGrid
    }

    private var originY: CGFloat {
        layout.origin.y + (yGrid?.origin ?? 0)
    }

    private var yOriginVisible: Bool {
        layout.isVisible(y: originY)
    }

}

struct Origin_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    var views: [LibraryItem] {

        LibraryItem(Origin(),
                    title: "Origin Decorator",
                    category: .other)

    }

}

struct Origin_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            LineChart(data: sampleShortTimeSeries, trimmedTo: .previousWeek, overlay: Origin())
                .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: .days(1)))
                .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
                .rectChart(originMark: .line(width: 3))
                .rectChart(xOriginColor: .green)
                .rectChart(yOriginColor: .red)
                .chartInsets(.all, 20)
                .frame(width: 300, height: 150)
                .border(Color.black)
            Spacer()

            LineChart(data: sampleShortTimeSeries, trimmedTo: .previousWeek, overlay: Origin())
                .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: .days(1)))
                .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
                .rectChart(originMark: .tic(length: 1, width: 2))
                .rectChart(xOriginColor: .green)
                .rectChart(yOriginColor: .red)
                .chartInsets(.all, 20)
                .frame(width: 300, height: 150)
                .border(Color.black)
            Spacer()

            LineChart(data: sampleShortTimeSeries, trimmedTo: .previousWeek, overlay: Origin())
                .rectChart(xAxisGrid: XAxisGrid(origin: .today, spacing: .days(1)))
                .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
                .rectChart(originMark: .positiveTic(length: 1, width: 3))
                .rectChart(xOriginColor: .green)
                .rectChart(yOriginColor: .red)
                .chartInsets(.all, 20)
                .frame(width: 300, height: 150)
                .border(Color.black)
            Spacer()
        }
    }
}
