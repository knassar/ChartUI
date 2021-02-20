//
//  RadialChartLayout.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

public struct RadialChartLayoutComposer<Content: View>: View {

    private var data: AnyCategorizedDataSeries
    private var geometry: GeometryProxy?
    private var content: () -> Content

    init(data: AnyCategorizedDataSeries, geometry: GeometryProxy?, @ViewBuilder content: @escaping () -> Content) {
        self.data = data
        self.geometry = geometry
        self.content = content
    }

    @Environment(\.radialSegmentsStyle)
    private var segmentsStyle: RadialSegmentsStyle

    @Environment(\.chartLayout)
    private var chartLayout: ChartLayout

    public var body: some View {
        content()
            .categorizedChartData(data)
            .chartLayout(localFrame: localFrame)
            .environment(\.radialChartLayout, radialLayout())
    }

    private var localFrame: CGRect {
        geometry?.frame(in: .local) ?? .zero
    }

    private func radialLayout() -> RadialChartLayout {
        RadialChartLayout(data: data, localFrame: localFrame, insets: chartLayout.insets, segmentsStyle: segmentsStyle)
    }

}

struct RadialChartLayoutKey: EnvironmentKey {
    static let defaultValue: RadialChartLayout = RadialChartLayout()
}

extension EnvironmentValues {

    public var radialChartLayout: RadialChartLayout {
        get { self[RadialChartLayoutKey.self] }
        set { self[RadialChartLayoutKey.self] = newValue }
    }

}

public struct RadialChartLayout {

    public var center = CGPoint.zero
    public var max: CGFloat = 0
    public var segments = [Segment]()
    public var localFrame = CGRect.zero
    public var insets = EdgeInsets()

    public var insetFrame: CGRect {
        CGRect(x: localFrame.minX + insets.leading,
               y: localFrame.minY + insets.top,
               width: localFrame.width - (insets.leading + insets.trailing),
               height: localFrame.height - (insets.top + insets.bottom))
    }

    public var size: CGSize {
        insetFrame.size
    }

    public func segment(at index: Int) -> Segment? {
        guard index < segments.count else { return nil }
        return segments[index]
    }

    init() {

    }

    init(data: AnyCategorizedDataSeries, localFrame: CGRect, insets: EdgeInsets, segmentsStyle: RadialSegmentsStyle) {
        self.insets = insets
        self.localFrame = localFrame
        self.recalculate(with: data, segmentsStyle: segmentsStyle)
    }

    public struct Segment: Animatable {
        public var datum: AnyCategorizedDatum
        public var center: CGPoint
        public var startAngle: Angle
        public var midAngle: Angle
        public var endAngle: Angle
        public var outerRadius: CGFloat
        public var innerRadius: CGFloat

        public var sweep: Angle {
            endAngle - startAngle
        }

        public var isValid: Bool {
            datum.isValid && center.isValid && startAngle.isValid && endAngle.isValid && outerRadius.isValid && innerRadius.isValid
        }

        public func bisectorPoint(at radius: CGFloat) -> CGPoint {
            CGPoint(x: center.x + cos(CGFloat(midAngle.radians)) * radius,
                    y: center.y + sin(CGFloat(midAngle.radians)) * radius)
        }

        public typealias AnimatableData = AnimatablePair<
            CGPoint.AnimatableData, // center
            AnimatablePair<
                AnimatablePair<Double, Double>, // startAngle.radians, endAngle.radians
                AnimatablePair<CGFloat, CGFloat> // innerRadius, outerRadius
            >
        >

        public var animatableData: AnimatableData {
            get {
                AnimatablePair(
                    center.animatableData,
                    AnimatablePair(
                        AnimatablePair(startAngle.radians, endAngle.radians),
                        AnimatablePair(innerRadius, outerRadius)
                    )
                )
            }
            set {
                self.center.animatableData = newValue.first
                let angles = newValue.second.first
                let radii = newValue.second.second
                self.startAngle = Angle(radians: angles.first)
                self.endAngle = Angle(radians: angles.second)
                self.midAngle = startAngle + ((endAngle - startAngle) / 2)
                self.innerRadius = radii.first
                self.outerRadius = radii.second
            }
        }

    }

}

extension RadialChartLayout {

    private mutating func recalculate(with data: AnyCategorizedDataSeries, segmentsStyle: RadialSegmentsStyle) {

        self.center = CGPoint(x: insetFrame.width / 2 + insets.leading, y: insetFrame.height / 2 + insets.top)

        segments.removeAll()
        let maxProjection = data.categorizedData.map { segmentsStyle.projection(for: $0) } .reduce(0) { Swift.max($0, $1) }
        let availableRadius = (min(size.width, size.height) / 2) - maxProjection
        let total = data.categorizedData.map { $0.yValue } .reduce(0) { $0 + $1 }
        self.max = data.categorizedData.map { $0.yValue } .reduce(0) { Swift.max($0, $1) } / total

        var lastStart = Angle(degrees: -90) // "up"
        self.segments = data.categorizedData.map { datum in
            let end = lastStart + Angle(degrees: Double(datum.yValue / total) * 360)
            let segment = calculateSegment(for: datum, start: lastStart, end: end, availableRadius: availableRadius, segmentsStyle: segmentsStyle)
            lastStart = end
            return segment
        }
    }

    private func calculateSegment(for datum: AnyCategorizedDatum, start: Angle, end: Angle, availableRadius: CGFloat, segmentsStyle: RadialSegmentsStyle) -> Segment {
        // Center & Projection
        var center = self.center
        let projection = segmentsStyle.projection(for: datum)
        let midAngle = start + ((end - start) / 2)
        if projection > 0 {
            center = CGPoint(x: center.x + cos(CGFloat(midAngle.radians)) * projection,
                             y: center.y + sin(CGFloat(midAngle.radians)) * projection)
        }

        // Radius
        var outerRadius: CGFloat = 0
        var innerRadius: CGFloat = 0
        let rRatio = CGFloat((end - start).degrees / 360)
        switch segmentsStyle.outerRadius(for: datum) {
        case let .constant(r):
            outerRadius = r
        case .auto:
            outerRadius = availableRadius
        case .proportional:
            outerRadius = availableRadius - availableRadius * (max - rRatio)
        case .inverselyProportional:
            outerRadius = availableRadius - availableRadius * rRatio
        }

        switch segmentsStyle.innerRadius(for: datum) {
        case let .constant(r):
            innerRadius = r
        case .auto:
            innerRadius = availableRadius * 0.75
        case .proportional:
            innerRadius = availableRadius * 0.5 - (availableRadius / 2) * (max - rRatio)
        case .inverselyProportional:
            innerRadius = availableRadius * 0.5 - (availableRadius / 2) * rRatio
        }

        return Segment(datum: datum,
                       center: center,
                       startAngle: start,
                       midAngle: midAngle,
                       endAngle: end,
                       outerRadius: outerRadius,
                       innerRadius: innerRadius)
    }

}
