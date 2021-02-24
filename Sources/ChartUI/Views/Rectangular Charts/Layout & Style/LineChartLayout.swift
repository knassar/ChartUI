//
//  LineChartLayout.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/21/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

public struct LineChartLayoutComposer<Underlay: View, Content: View>: View {

    private var data: AnyDataSeries
    private var geometry: GeometryProxy?
    private var underlay: Underlay
    private var content: Content
    private var xRange: Range<CGFloat>?

    init(data: AnyDataSeries, geometry: GeometryProxy?, xRange: Range<CGFloat>? = nil, underlay: Underlay, content: Content) {
        self.data = data
        self.geometry = geometry
        self.underlay = underlay
        self.content = content
        self.xRange = xRange
    }

    @Environment(\.chartLayout)
    private var chartLayout: ChartLayout

    @Environment(\.lineChartStyle)
    private var lineChartStyle: LineChartStyle

    public var body: some View {
        let rectLayout = self.rectLayout()
        let lineLayout = self.lineLayout(with: rectLayout)
        ZStack {
            ForEach(lineLayout.visibleSegments) { segment in
                underlay
                    .environment(\.lineChartSegment, segment)
            }
            ForEach(lineLayout.visibleSegments) { segment in
                content
                    .environment(\.lineChartSegment, segment)
            }
        }
        .orderedChartData(data)
        .attachScrollInteraction(with: offsetBinding)
        .chartLayout(localFrame: localFrame)
        .environment(\.lineChartLayout, lineLayout)
        .environment(\.rectangularChartLayout, rectLayout)
    }

    private var localFrame: CGRect {
        geometry?.frame(in: .local) ?? .zero
    }

    private func rectLayout() -> RectangularChartLayout {
        RectangularChartLayout(data: data, localFrame: localFrame, insets: chartLayout.insets, xRange: xRange)
    }

    private func lineLayout(with rectLayout: RectangularChartLayout) -> LineChartLayout {
        LineChartLayout(data: data, xRange: xRange, offset: offsetBinding.wrappedValue, rectLayout: rectLayout)
    }

    private var offsetBinding: Binding<CGFloat> {
        return lineChartStyle.scrollOffsetBinding ?? $defaultScrollOffset
    }

    @State
    private var defaultScrollOffset: CGFloat = 1

}

// MARK: - Layout Environment Key

struct LineChartLayoutKey: EnvironmentKey {
    static let defaultValue: LineChartLayout = LineChartLayout()
}

extension EnvironmentValues {

    public var lineChartLayout: LineChartLayout {
        get { self[LineChartLayoutKey.self] }
        set { self[LineChartLayoutKey.self] = newValue }
    }

}

// MARK: - Line Frame Layout

struct LineChartSegmentKey: EnvironmentKey {
    static let defaultValue: LineChartLayout.Segment = .empty
}

extension EnvironmentValues {

    public var lineChartSegment: LineChartLayout.Segment {
        get { self[LineChartSegmentKey.self] }
        set { self[LineChartSegmentKey.self] = newValue }
    }

}

// MARK: - Layout

public struct LineChartLayout {

    public private(set) var absoluteDataBounds = RectangularChartLayout.Bounds()
    public private(set) var xDataBoundsWithInsets: ClosedRange<CGFloat> = 0...0
    public private(set) var segments = [Segment]()
    public private(set) var localFrame = CGRect.zero
    public private(set) var insets = EdgeInsets()
    public private(set) var xRange: Range<CGFloat>?

    private var dataToLayoutTransformX: (CGFloat) -> CGFloat = { $0 }
    private var layoutToDataTransformX: (CGFloat) -> CGFloat = { $0 }
    private var visibleRangeX: ClosedRange<CGFloat> = 0...0

    public private(set) var scrollOffset: CGFloat = 1
    public private(set) var maxScrollOffset: CGFloat = 80

    public var insetFrame: CGRect {
        CGRect(x: localFrame.minX + insets.leading,
               y: localFrame.minY + insets.top,
               width: localFrame.width - (insets.leading + insets.trailing),
               height: localFrame.height - (insets.top + insets.bottom))
    }

    public var size: CGSize {
        insetFrame.size
    }

    public var visibleSegments: [Segment] {
        segments.filter { $0.isVisible }
    }

    public var dataStart: CGFloat {
        xRange?.lowerBound ?? absoluteDataBounds.start
    }

    public var dataEnd: CGFloat {
        xRange?.upperBound ?? absoluteDataBounds.end
    }

    init() {

    }

    init(data: AnyDataSeries, xRange: Range<CGFloat>?, offset: CGFloat, rectLayout: RectangularChartLayout) {
        self.absoluteDataBounds = rectLayout.absoluteDataBounds
        self.insets = rectLayout.insets
        self.localFrame = rectLayout.localFrame
        self.xRange = xRange
        self.scrollOffset = offset
        self.recalculate(with: data, in: rectLayout)
    }

}

// MARK: - Coordinate Space Conversion

extension LineChartLayout {

    public func xInLayout(fromDataX x: CGFloat) -> CGFloat {
        dataToLayoutTransformX(x) + insets.leading
    }

}

extension LineChartLayout {

    static let pointsPerFrame = 500

    private mutating func recalculate(with data: AnyDataSeries, in rectLayout: RectangularChartLayout) {

        // *** These values build upon each other, so order matters here *** 

        // 1. compute the horizontal units
        let available = insetFrame.size
        let unitX = available.width / (dataEnd - dataStart)

        // 2. Adjust the visible range according to the scroll offset
        self.maxScrollOffset = absoluteDataBounds.size.width * unitX - available.width * 0.75
        let scroll = (maxScrollOffset - scrollOffset * maxScrollOffset) / unitX
        self.xRange = (dataStart - scroll)..<(dataEnd - scroll)

        // 3. setup the transforms based on visible range
        let start = self.dataStart
        self.dataToLayoutTransformX = { ($0 - start) * unitX }

        // 4. compute the segment frames
        let dataCount = data.count
        // the data chunked into `frameWidth`-sized arrays
        self.segments = stride(from: 0, to: dataCount, by: Self.pointsPerFrame).map {
            lineFrame(at: $0, through: min($0 + Self.pointsPerFrame + 1, dataCount), from: data, in: rectLayout)
        }

        // 5. set the overall bounds in view-units
        self.xDataBoundsWithInsets = (dataStart - insets.leading / unitX)...(dataEnd + insets.trailing / unitX)
    }

    private func lineFrame(at index: Int, through: Int, from data: AnyDataSeries, in rectLayout: RectangularChartLayout) -> Segment {
        let frameData = Array(data.allData[index..<through])
        guard
            let first = frameData.first,
            let last = frameData.last
        else {
            return .empty
        }

        let absRect = CGRect(x: first.xValue,
                             y: absoluteDataBounds.minimum,
                              width: last.xValue - first.xValue,
                              height: absoluteDataBounds.maximum)

        let rect = CGRect(x: xInLayout(fromDataX: absRect.origin.x),
                          y: rectLayout.yInLayout(fromDataY: absRect.origin.y),
                          width: xInLayout(fromDataX: last.xValue) - xInLayout(fromDataX: first.xValue),
                          height: insetFrame.height).standardized

        let relativePoints = frameData.map { datum in
            CGPoint(x: (datum.xValue - absRect.minX) / absRect.width,
                    y: 1 - (datum.yValue - absRect.minY) / absRect.height)
        }

        var position = Segment.Position.middle
        if index == 0 {
            position.insert(.first)
        }
        if through == data.count {
            position.insert(.last)
        }

        let isVisisble = (dataStart...dataEnd).overlaps(first.xValue...last.xValue)

        return Segment(data: frameData, rect: rect, relativePoints: relativePoints, position: position, isVisible: isVisisble)
    }

    public struct Segment: Identifiable, Animatable {

        public var id: CGFloat {
            data.first?.xValue ?? .nan
        }

        public var data: [AnyDatum]
        public var rect: CGRect
        public var relativePoints: [CGPoint]
        public var points: [CGPoint]
        public var position: Position
        public var isVisible: Bool

        public var startX: CGFloat {
            data.first?.xValue ?? .nan
        }

        public var endX: CGFloat {
            data.last?.xValue ?? .nan
        }

        public func isVisible(x: CGFloat) -> Bool {
            guard startX.isValid, endX.isValid else { return false }
            return (startX...endX).contains(x)
        }

        public static let empty = Segment(data: [], rect: .zero, relativePoints: [], position: [], isVisible: false)

        init(data: [AnyDatum], rect: CGRect, relativePoints: [CGPoint], position: Position, isVisible: Bool) {
            self.data = data
            self.rect = rect
            self.relativePoints = relativePoints
            self.position = position
            self.isVisible = isVisible
            self.points = []
            self.recomputePoints()
        }

        public func xInSegment(fromDataX x: CGFloat) -> CGFloat {
            let percentX = (x - startX) / (endX - startX)
            return rect.width * percentX + rect.minX
        }

        public func points(for datums: [AnyDatum]) -> [CGPoint] {
            var points = [CGPoint]()
            for i in 0..<data.count where datums.contains(where: { $0 == data[i] }) {
                points.append(self.points[i])
            }
            return points
        }

        public var animatableData: CGRect.AnimatableData {
            get {
                rect.animatableData
            }
            set {
                rect.animatableData = newValue
                recomputePoints()
            }
        }

        private mutating func recomputePoints() {
            self.points = relativePoints.map {
                CGPoint(x: $0.x * rect.width + rect.minX,
                        y: $0.y * rect.height + rect.minY - rect.height)
            }
        }

        public struct Position: OptionSet {
            public var rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            static let first = Position(rawValue: 1 << 0)
            static let last = Position(rawValue: 1 << 1)
            static let middle = Position(rawValue: 1 << 2)
            static let singular = Position(rawValue: .max)
        }

    }

}
