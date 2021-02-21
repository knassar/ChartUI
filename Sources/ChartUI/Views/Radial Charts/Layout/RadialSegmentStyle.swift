//
//  RadialSegmentStyle.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct RadialSegmentsStyleKey: EnvironmentKey {
    static let defaultValue: RadialSegmentsStyle = RadialSegmentsStyle()
}

extension EnvironmentValues {

    public var radialSegmentsStyle: RadialSegmentsStyle {
        get {
            self[RadialSegmentsStyleKey.self]
        }
        set {
            self[RadialSegmentsStyleKey.self] = newValue
        }
    }

}

public struct RadialSegmentsStyle {

    var defaultValues = RadialSegmentStyle()
    var segments = [AnyHashable: RadialSegmentStyle]()

    public func projection(for datum: AnyCategorizedDatum) -> CGFloat {
        segments[datum.id]?.projection ?? defaultValues.projection ?? 0
    }

    public func outerRadius(for datum: AnyCategorizedDatum) -> RadialSegmentsStyle.Radius {
        segments[datum.id]?.outerRadius ?? defaultValues.outerRadius ?? .auto
    }

    public func innerRadius(for datum: AnyCategorizedDatum) -> RadialSegmentsStyle.Radius {
        segments[datum.id]?.innerRadius ?? defaultValues.innerRadius ?? .auto
    }

    public enum Radius {
        case auto,
             constant(CGFloat),
             proportional,
             inverselyProportional

    }

}

struct RadialSegmentStyle {

    public var projection: CGFloat?
    public var outerRadius: RadialSegmentsStyle.Radius?
    public var innerRadius: RadialSegmentsStyle.Radius?

}

private struct RadialSegmentsStyleWrapper<StyleValue>: ViewModifier {

    @Environment(\.radialSegmentsStyle)
    private var currentStyle: RadialSegmentsStyle

    var modifier: (RadialSegmentsStyle) -> RadialSegmentsStyle

    init(segmentId: AnyHashable, value: StyleValue, keyPath: WritableKeyPath<RadialSegmentStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            var values = style.segments[segmentId] ?? RadialSegmentStyle()
            values[keyPath: keyPath] = value
            style.segments[segmentId] = values
            return style
        }
    }

    init(segmentValue: StyleValue, keyPath: WritableKeyPath<RadialSegmentStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            style.defaultValues[keyPath: keyPath] = segmentValue
            return style
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.radialSegmentsStyle, modifier(currentStyle))
    }

}

// MARK: - Radial Chart Default Segment Style Modifiers

extension View {

    public func radialChart(projection: CGFloat) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentValue: projection, keyPath: \.projection))
    }

    public func radialChart(outerRadius: RadialSegmentsStyle.Radius) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentValue: outerRadius, keyPath: \.outerRadius))
    }

    public func radialChart(outerRadius: CGFloat) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentValue: .constant(outerRadius), keyPath: \.outerRadius))
    }

    public func radialChart(innerRadius: RadialSegmentsStyle.Radius) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentValue: innerRadius, keyPath: \.innerRadius))
    }

    public func radialChart(innerRadius: CGFloat) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentValue: .constant(innerRadius), keyPath: \.innerRadius))
    }

}

// MARK: - Radial Chart Segment-Specific Segment Style Modifiers

extension View {

    public func radialChart<ID: Hashable>(projection: CGFloat, for segmentId: ID) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentId: AnyHashable(segmentId), value: projection, keyPath: \.projection))
    }

    public func radialChart<ID: Hashable>(outerRadius: RadialSegmentsStyle.Radius, for segmentId: ID) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentId: AnyHashable(segmentId), value: outerRadius, keyPath: \.outerRadius))
    }

    public func radialChart<ID: Hashable>(outerRadius: CGFloat, for segmentId: ID) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentId: AnyHashable(segmentId), value: .constant(outerRadius), keyPath: \.outerRadius))
    }

    public func radialChart<ID: Hashable>(innerRadius: RadialSegmentsStyle.Radius, for segmentId: ID) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentId: AnyHashable(segmentId), value: innerRadius, keyPath: \.innerRadius))
    }

    public func radialChart<ID: Hashable>(innerRadius: CGFloat, for segmentId: ID) -> some View {
        self.modifier(RadialSegmentsStyleWrapper(segmentId: AnyHashable(segmentId), value: .constant(innerRadius), keyPath: \.innerRadius))
    }

}

struct RadialSegmentStyle_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: AnyView) -> [LibraryItem] {

        LibraryItem(base.radialChart(projection: 20),
                    title: "Radial Seg. Projection",
                    category: .effect)

        LibraryItem(base.radialChart(outerRadius: RadialSegmentsStyle.Radius.auto),
                    title: "Radial Seg. Outer Radius Style",
                    category: .effect)

        LibraryItem(base.radialChart(outerRadius: 100.0),
                    title: "Radial Seg. Outer Radius",
                    category: .effect)

        LibraryItem(base.radialChart(innerRadius: RadialSegmentsStyle.Radius.auto),
                    title: "Radial Seg. Inner Radius Style",
                    category: .effect)

        LibraryItem(base.radialChart(innerRadius: 60.0),
                    title: "Radial Seg. Inner Radius",
                    category: .effect)
    }

}
