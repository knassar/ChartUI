//
//  LinearChartLayout.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

public struct LinearChartLayoutComposer<Content: View>: View {

    private var data: AnyDataSeries
    private var geometry: GeometryProxy?
    private var content: () -> Content
    private var xRange: Range<CGFloat>?

    init(data: AnyDataSeries, geometry: GeometryProxy?, xRange: Range<CGFloat>? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.data = data
        self.geometry = geometry
        self.content = content
        self.xRange = xRange
    }

    init(data: AnyCategorizedDataSeries, geometry: GeometryProxy?, @ViewBuilder content: @escaping () -> Content) {
        self.data = data
        self.geometry = geometry
        self.content = content
    }

    @Environment(\.chartLayout)
    private var chartLayout: ChartLayout

    @Environment(\.linearBarsStyle)
    private var barsStyle: LinearBarsStyle

    public var body: some View {
        switch data {
        case let categorizedData as AnyCategorizedDataSeries:
            content()
                .categorizedChartData(categorizedData)
                .chartLayout(localFrame: localFrame)
                .environment(\.linearChartLayout, linearLayout())
        default:
            content()
                .orderedChartData(data)
                .chartLayout(localFrame: localFrame)
                .environment(\.linearChartLayout, linearLayout())
        }
    }

    private var localFrame: CGRect {
        geometry?.frame(in: .local) ?? .zero
    }

    private func linearLayout() -> LinearChartLayout {
        switch data {
        case let categorizedData as AnyCategorizedDataSeries:
            return LinearChartLayout(data: categorizedData, localFrame: localFrame, insets: chartLayout.insets, barsStyle: barsStyle)
        default:
            return LinearChartLayout(data: data, localFrame: localFrame, insets: chartLayout.insets, xRange: xRange)
        }
    }

}

extension LinearChartLayoutComposer: Animatable {

    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            if let xRange = xRange {
                return AnimatablePair(xRange.lowerBound, xRange.upperBound)
            } else {
                return AnimatablePair(0, 0)
            }
        }
        set {
            if newValue.first == newValue.second {
                xRange = nil
            } else {
                xRange = min(newValue.first, newValue.second)..<max(newValue.first, newValue.second)
            }
        }
    }

}

// MARK: - Layout Environment Key

struct LinearChartLayoutKey: EnvironmentKey {
    static let defaultValue: LinearChartLayout = LinearChartLayout()
}

extension EnvironmentValues {

    public var linearChartLayout: LinearChartLayout {
        get { self[LinearChartLayoutKey.self] }
        set { self[LinearChartLayoutKey.self] = newValue }
    }

}

// MARK: - AnyDataSeries Layout

public struct LinearChartLayout {

    public private(set) var visibleDataPoints: [CGPoint] = []
    public private(set) var absoluteDataBounds = Bounds()
    public private(set) var visibleDataBounds = Bounds()
    public private(set) var origin: CGPoint = .zero
    public private(set) var segments = [Segment]()
    public private(set) var localFrame = CGRect.zero
    public private(set) var insets = EdgeInsets()
    public private(set) var xRange: Range<CGFloat>?

    private var dataToLayoutTransformX: (CGFloat) -> CGFloat = { $0 }
    private var dataToLayoutTransformY: (CGFloat) -> CGFloat = { $0 }
    private var layoutToDataTransformX: (CGFloat) -> CGFloat = { $0 }
    private var layoutToDataTransformY: (CGFloat) -> CGFloat = { $0 }
    private var visibleRangeX: ClosedRange<CGFloat> = 0...0

    public var insetFrame: CGRect {
        CGRect(x: localFrame.minX + insets.leading,
               y: localFrame.minY + insets.top,
               width: localFrame.width - (insets.leading + insets.trailing),
               height: localFrame.height - (insets.top + insets.bottom))
    }

    public var size: CGSize {
        insetFrame.size
    }

    init() {

    }

    init(data: AnyDataSeries, localFrame: CGRect, insets: EdgeInsets, xRange: Range<CGFloat>?) {
        self.insets = insets
        self.localFrame = localFrame
        self.recalculate(with: data)
        self.xRange = xRange
        self.recalculate(with: data)
    }

}

// MARK: - Coordinate Space Conversion

extension LinearChartLayout {

    public func visibleLayoutPoint(for datum: AnyDatum) -> CGPoint? {
        let point = CGPoint(x: datum.xValue, y: datum.yValue)
        guard isVisible(point) else { return nil }
        return pointInLayout(fromDataPoint: point)
    }

    public func isVisible(_ point: CGPoint) -> Bool {
        visibleRangeX.contains(point.x)
    }

    public func isVisible(x: CGFloat) -> Bool {
        visibleRangeX.contains(x)
    }

    public func isVisible(y: CGFloat) -> Bool {
        (visibleDataBounds.minimum...visibleDataBounds.maximum).contains(y)
    }

    public func pointInLayout(from datum: AnyDatum) -> CGPoint {
        pointInLayout(fromDataPoint: CGPoint(x: datum.xValue, y: datum.yValue))
    }

    public func pointInLayout(fromDataPoint point: CGPoint) -> CGPoint {
        dataToLayoutTransform(point)
    }

    public func dataScalePoint(fromPointInLayout point: CGPoint) -> CGPoint {
        layoutToDataTransform(point)
    }

    public func xInLayout(fromDataX x: CGFloat) -> CGFloat {
        dataToLayoutTransformX(x)
    }

    public func yInLayout(fromDataY y: CGFloat) -> CGFloat {
        dataToLayoutTransformY(y)
    }

    private func dataToLayoutTransform(_ point: CGPoint) -> CGPoint {
        CGPoint(x: dataToLayoutTransformX(point.x), y: dataToLayoutTransformY(point.y))
    }

    private func layoutToDataTransform(_ point: CGPoint) -> CGPoint {
        CGPoint(x: layoutToDataTransformX(point.x), y: layoutToDataTransformY(point.y))
    }

}

extension LinearChartLayout {

    private mutating func recalculate(with data: AnyDataSeries) {
        computeAbsoluteBounds(of: data)

        let available = insetFrame.size
        let unitX = available.width / (dataEnd - dataStart)
        let unitY = available.height / absoluteDataBounds.size.height

        computeLayoutMetrics(with: unitX, unitY)

        var minVisibleX: CGFloat = 0
        var maxVisibleX = dataEnd
        let points: [CGPoint] = data.allData.map { datum in
            let point = CGPoint(x: datum.xValue, y: datum.yValue)
            if datum.xValue < dataStart {
                minVisibleX = datum.xValue
            }
            if  maxVisibleX != dataEnd && datum.xValue > dataEnd {
                maxVisibleX = datum.xValue
            }
            return point
        }
        self.visibleRangeX = min(minVisibleX, maxVisibleX)...max(minVisibleX, maxVisibleX)

        self.visibleDataPoints = points
            .filter { isVisible($0) }
            .map { dataToLayoutTransform($0) }

    }

    private var dataStart: CGFloat {
        xRange?.lowerBound ?? absoluteDataBounds.start
    }

    private var dataEnd: CGFloat {
        xRange?.upperBound ?? absoluteDataBounds.end
    }

    private mutating func computeAbsoluteBounds(of data: AnyDataSeries) {
        self.absoluteDataBounds = Bounds(origin: .zero,
                                         start: data.first.xValue,
                                         end: data.last.xValue,
                                         maximum: data.maximum.yValue,
                                         minimum: abs(Swift.min(data.minimum.yValue, 0)))
    }

    private mutating func computeLayoutMetrics(with unitX: CGFloat, _ unitY: CGFloat) {

        self.visibleDataBounds = Bounds(origin: .zero,
                                        start: dataStart - insets.leading / unitX,
                                        end: dataEnd + insets.trailing / unitX,
                                        maximum: absoluteDataBounds.maximum + insets.top / unitY,
                                        minimum: absoluteDataBounds.minimum - insets.bottom / unitY)

        self.origin = CGPoint(x: 0 - dataStart * unitX,
                              y: 0 - absoluteDataBounds.minimum * unitY)

        let yOffset = size.height
        let yInset = insets.top
        let dataStart = self.dataStart
        let dataMin = absoluteDataBounds.minimum

        self.dataToLayoutTransformX = { ($0 - dataStart) * unitX }
        self.dataToLayoutTransformY = { yOffset - (($0 - dataMin) * unitY) + yInset }

    }

}

// MARK: - AnyCategorizedDataSeries Layout

extension LinearChartLayout {

    public func segment(at index: Int) -> Segment? {
        guard index < segments.count else { return nil }
        return segments[index]
    }


    init(data: AnyCategorizedDataSeries, localFrame: CGRect, insets: EdgeInsets, barsStyle: LinearBarsStyle) {
        self.insets = insets
        self.localFrame = localFrame
        self.recalculate(with: data, barsStyle: barsStyle)
    }

    private mutating func recalculate(with data: AnyCategorizedDataSeries, barsStyle: LinearBarsStyle) {
        self.recalculate(with: data)

        let barCount = data.categorizedData.count

        let spacerCount = barCount - 1
        let available = insetFrame.size
        var (availableWidth, availableHeight) = barsStyle.orientation == .horizontal
            ? (available.width, available.height)
            : (available.height, available.width)

        var spacing: CGFloat = .nan
        var autoWidthSegmentCount = 0

        self.segments = data.categorizedData.map { datum in
            let height = datum.yValue / absoluteDataBounds.maximum * (availableHeight - origin.y)
            switch barsStyle.width(for: datum) {
            case .auto:
                autoWidthSegmentCount += 1
                return Segment(datum: datum, rect: CGRect(origin: .invalid, size: CGSize(width: .nan, height: height)))
            case let .constant(width):
                availableWidth -= width
                return Segment(datum: datum, rect: CGRect(origin: .invalid, size: CGSize(width: width, height: height)))
            }
        }

        // if spacing is set as constant, allocate it
        if case let .constant(width) = barsStyle.spacing {
            spacing = width
            availableWidth -= width * CGFloat(spacerCount)
        }

        // set the auto bar widths
        let reservedForSpacing = spacing.isNaN ? availableWidth * 0.2 : 0
        let autoBarWidth = (availableWidth - reservedForSpacing) / CGFloat(autoWidthSegmentCount)
        self.segments = segments.map { segment in
            switch segment.rect.width.isNaN {
            case true:
                var rect = segment.rect
                rect.size.width = autoBarWidth
                availableWidth -= autoBarWidth
                return Segment(datum: segment.datum, rect: rect)
            case false:
                return segment
            }
        }

        // otherwise use up what's left as spacing
        if case .auto = barsStyle.spacing {
            spacing = availableWidth / CGFloat(spacerCount)
        }

        // set the bar positions
        var x = insetFrame.minX
        self.segments = segments.map { segment in
            var rect = segment.rect
            rect = CGRect(origin: CGPoint(x: x, y: yInLayout(fromDataY: origin.y)),
                          size: CGSize(width: rect.width, height: rect.height * -1)).standardized
            x += spacing + rect.width
            return Segment(datum: segment.datum, rect: rect)
        }

    }

    public struct Segment: Animatable {
        public var datum: AnyCategorizedDatum
        public var rect: CGRect

        public var isValid: Bool {
            datum.isValid && rect.isValid
        }

        public typealias AnimatableData = CGRect.AnimatableData

        public var animatableData: AnimatableData {
            get {
                rect.standardized.animatableData
            }
            set {
                self.rect.animatableData = newValue
            }
        }

    }

    public struct Bounds {
        public var origin: CGPoint = .zero
        public var start: CGFloat = 0
        public var end: CGFloat = 0
        public var maximum: CGFloat = 0
        public var minimum: CGFloat = 0

        public var size: CGSize {
            CGSize(width: end - start, height: maximum - minimum)
        }
    }

    public enum Orientation {
        case horizontal, vertical
    }

}
