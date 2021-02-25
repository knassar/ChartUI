//
//  CategorizedDataStyle.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct CategorizedDataStyleKey: EnvironmentKey {
    static let defaultValue: CategorizedDataStyle = CategorizedDataStyle()
}

extension EnvironmentValues {

    public var categorizedDataStyle: CategorizedDataStyle {
        get {
            self[CategorizedDataStyleKey.self]
        }
        set {
            self[CategorizedDataStyleKey.self] = newValue
        }
    }

}

public struct CategorizedDataStyle {

    /// Read-only access to the data being plotted
    public fileprivate(set) var data: AnyCategorizedDataSeries = EmptyDataSeries()

    /// The assigned legend style
    public fileprivate(set) var legendStyle: LegendStyle? = nil

    fileprivate var colors: ColorSet? = BasicColorSet()
    fileprivate var defaultValues = Values()
    fileprivate var datumValues = [AnyHashable: Values]()

    public typealias SegmentTapHandler = (AnyCategorizedDatum?) -> Void

    var tapHandler: SegmentTapHandler?
    var momentaryTapHandler: SegmentTapHandler?

    struct Values {
        var zIndex: Int?
        var fill: Color?
        var stroke: Color?
        var strokeWidth: CGFloat?
    }

    /// The computed Z index for the chart segment of the given datum
    ///
    /// This function takes into account individual Z-index overrides introduced by modifiers
    /// - Parameter datum: A categorized datum to retrieve the segment Z index for
    /// - Returns: A computed Z index
    public func zIndex(for datum: AnyCategorizedDatum) -> Int {
        datumValues[datum.id]?.zIndex ?? 0
    }

    /// The computed fill color fo rthe chart segment of the given datum
    ///
    /// This function takes into account individual color overrides introduced by modifiers, consults the current ColorSet, any assigned defaults, and ultimately defaults to `.blue` if no color could be computed.
    /// - Parameter datum: A categorized datum to retrieve the segment fill color for
    /// - Returns: A computed fill color
    public func fill(for datum: AnyCategorizedDatum) -> Color {
        if let fill = datumValues[datum.id]?.fill {
            return fill
        } else if let color = colors?.color(at: datum.index) {
            return color
        } else {
            return defaultValues.fill ?? .blue
        }
    }

    /// The computed stroke color fo rthe chart segment of the given datum
    ///
    /// This function takes into account individual color overrides introduced by modifiers, any assigned defaults, and ultimately defaults to `.white` if no color has been assigned.
    /// - Parameter datum: A categorized datum to retrieve the segment stroke color for
    /// - Returns: A computed stroke color
    public func stroke(for datum: AnyCategorizedDatum) -> Color {
        datumValues[datum.id]?.stroke ?? defaultValues.stroke ?? .white
    }

    /// The computed stroke width in points fo rthe chart segment of the given datum
    ///
    /// This function takes into account individual `strokeWidth` overrides introduced by modifiers, any assigned defaults, and ultimately defaults to `1.0` if no `strokeWidth` has been assigned
    /// - Parameter datum: A categorized datum to retrieve the segment `strokeWidth` for
    /// - Returns: A computed `strokeWidth` in points
    public func strokeWidth(for datum: AnyCategorizedDatum) -> CGFloat {
        datumValues[datum.id]?.strokeWidth ?? defaultValues.strokeWidth ?? 1
    }

}

private struct CategorizedDataStyleWrapper<StyleValue>: ViewModifier {

    @Environment(\.categorizedDataStyle)
    private var currentStyle: CategorizedDataStyle

    var modifier: (CategorizedDataStyle) -> CategorizedDataStyle

    init(value: StyleValue, keyPath: WritableKeyPath<CategorizedDataStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            style[keyPath: keyPath] = value
            return style
        }
    }

    init(modifier: @escaping (CategorizedDataStyle) -> CategorizedDataStyle) where StyleValue == Never {
        self.modifier = modifier
    }

    init(datumId: AnyHashable, value: StyleValue, keyPath: WritableKeyPath<CategorizedDataStyle.Values, StyleValue>) {
        self.modifier = { style in
            var style = style
            var values = style.datumValues[datumId] ?? CategorizedDataStyle.Values()
            values[keyPath: keyPath] = value
            style.datumValues[datumId] = values
            return style
        }
    }

    init(datumValue: StyleValue, keyPath: WritableKeyPath<CategorizedDataStyle.Values, StyleValue>) {
        self.modifier = { style in
            var style = style
            style.defaultValues[keyPath: keyPath] = datumValue
            return style
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.categorizedDataStyle, modifier(currentStyle))
    }

}

// MARK: - Categorized Data Default datum Style Modifiers

extension View {

    /// Sets a Z-index for all chart segments.
    ///
    /// The Z-index property of a chart segment controls in what order they are rendered within the chart. This modifier is mostly useful for resetting individually set segments, or in conjunction with the individual segment Z-index modifier.
    /// - Parameter zIndex: An integer Z-index to apply to all segments within a chart
    /// - Returns: A modified view
    public func chartSegments(zIndex: Int) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumValue: zIndex, keyPath: \.zIndex))
    }

    /// Sets a common fill color for all chart segments.
    ///
    /// Fill colors set with `chartSegment(fillColor:for:)` will always override the common fill color.
    /// - Parameter color: A fill color to use for all chart segments
    /// - Returns: A modified view
    public func chartSegments(fillColor color: Color) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumValue: color, keyPath: \.fill))
    }

    /// Sets a common stroke color for all chart segments.
    ///
    /// Stroke colors set with `chartSegment(strokeColor:for:)` will always override the common stroke color.
    /// - Parameter color: A stroke color to use for all chart segments
    /// - Returns: A modified view
    public func chartSegments(strokeColor color: Color) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumValue: color, keyPath: \.stroke))
    }

    /// Sets a common stroke width in points for all chart segments.
    ///
    /// Stroke widths set with `chartSegment(strokeWidth:for:)` will always override the common stroke width.
    /// - Parameter color: A stroke width in points to use for all chart segments
    /// - Returns: A modified view
    public func chartSegments(strokeWidth: CGFloat) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumValue: strokeWidth, keyPath: \.strokeWidth))
    }

}

// MARK: - Categorized Data datum-Specific datum Style Modifiers

extension View {

    /// Sets a Z-index for a specific segment indicated by datum Id.
    ///
    /// Overrides any common value set by the more general `chartSegments(zIndex:)` modifier.
    /// - Parameters:
    ///     - zIndex: A Z-index to assign to the designated chart segment
    ///     - datumId: A categorized datum Id, indicating the chart segment
    /// - Returns: A modified view
    public func chartSegment<ID: Hashable>(zIndex: Int, for datumId: ID) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumId: AnyHashable(datumId), value: zIndex, keyPath: \.zIndex))
    }

    /// Sets a fill color for a specific segment indicated by datum Id.
    ///
    /// Overrides any common value set by the more general `chartSegments(fillColor:)` modifier.
    /// - Parameters:
    ///     - fillColor: A fill color to assign to the designated chart segment
    ///     - datumId: A categorized datum Id, indicating the chart segment
    /// - Returns: A modified view
    public func chartSegment<ID: Hashable>(fillColor color: Color, for datumId: ID) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumId: AnyHashable(datumId), value: color, keyPath: \.fill))
    }

    /// Sets a stroke color for a specific segment indicated by datum Id.
    ///
    /// Overrides any common value set by the more general `chartSegments(strokeColor:)` modifier.
    /// - Parameters:
    ///     - strokeColor: A stroke color to assign to the designated chart segment
    ///     - datumId: A categorized datum Id, indicating the chart segment
    /// - Returns: A modified view
    public func chartSegment<ID: Hashable>(strokeColor color: Color, for datumId: ID) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumId: AnyHashable(datumId), value: color, keyPath: \.stroke))
    }

    /// Sets a stroke width in points for a specific segment indicated by datum Id.
    ///
    /// Overrides any common value set by the more general `chartSegments(strokeWidth:)` modifier.
    /// - Parameters:
    ///     - strokeWidth: A stroke width in points to assign to the designated chart segment
    ///     - datumId: A categorized datum Id, indicating the chart segment
    /// - Returns: A modified view
    public func chartSegment<ID: Hashable>(strokeWidth: CGFloat, for datumId: ID) -> some View {
        self.modifier(CategorizedDataStyleWrapper(datumId: AnyHashable(datumId), value: strokeWidth, keyPath: \.strokeWidth))
    }

}

// MARK: - Categorized Data Other Style Properties

extension View {

    /// Sets a `ColorSet` to apply to categorized charts for determining fill color for individual segments
    /// - Parameter colorSet: An instance conforming to ColorSet
    /// - Returns: A modified view
    public func chartSegments(colorSet: ColorSet) -> some View {
        self.modifier(CategorizedDataStyleWrapper(value: colorSet, keyPath: \.colors))
    }

}

// MARK: - Categorized Data Legend Style Modifiers

extension View {

    /// Sets the assigned LegendStyle for categorized charts.
    ///
    /// Call with no argument to activate a default legend. Call with `nil` to deactivate any legend.
    /// - Parameter style: An optional `LegendStyle`argument, or `nil`
    /// - Returns: A modified view
    public func chartLegend(style: LegendStyle? = DefaultLegendStyle()) -> some View {
        self.modifier(CategorizedDataStyleWrapper(modifier: { wrapped in
            var wrapped = wrapped
            wrapped.legendStyle = style
            return wrapped
        }))
    }

}

// MARK: Data Setup

extension View {

    func categorizedChartData(_ data: AnyCategorizedDataSeries) -> some View {
        self.modifier(CategorizedDataStyleWrapper(value: data, keyPath: \.data))
    }

}

// MARK: - Interactions

extension View {

    /// Adds a handler for tap gestures on segments of cateogorized data charts.
    ///
    /// The supplied handler will be invoked with an `AnyCategorizedDatum` when the datum's visual segment is tapped.
    /// If the chart includes a stand-alone Legend, taps on the legend rows will also invoke the handler.
    /// - Parameter handler: A touch handler to receive the tapped datum
    /// - Returns: A modified view
    public func onChartSegmentTapGesture(_ handler: CategorizedDataStyle.SegmentTapHandler?) -> some View {
        self.modifier(CategorizedDataStyleWrapper(modifier: { style in
            var style = style
            style.tapHandler = handler
            return style
        }))
    }

    /// Adds a handler for momentary touch gestures on segments of cateogorized data charts.
    ///
    /// The supplied handler will be invoked with an `AnyCategorizedDatum` when the datum's visual segment is touched, and invoked again with a `nil` argument when the touch is released.
    /// If the chart includes a stand-alone Legend, taps on the legend rows will also invoke the handler.
    /// - Parameter handler: A touch handler to receive the touch events
    /// - Returns: A modified view
    public func onChartSegmentMomentaryTouchGesture(_ handler: CategorizedDataStyle.SegmentTapHandler?) -> some View {
        self.modifier(CategorizedDataStyleWrapper(modifier: { style in
            var style = style
            style.momentaryTapHandler = handler
            return style
        }))
    }

}

// MARK: - Library Content

struct CategorizedDataStyle_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: AnyView) -> [LibraryItem] {

        LibraryItem(base.chartSegments(zIndex: 0),
                    title: "Chart Segments Z-Index",
                    category: .layout)

        LibraryItem(base.chartSegments(fillColor: .blue),
                    title: "Chart Segments Fill",
                    category: .effect)

        LibraryItem(base.chartSegments(strokeColor: .white),
                    title: "Chart Segments Stroke",
                    category: .effect)

        LibraryItem(base.chartSegments(strokeWidth: 1.0),
                    title: "Chart Seg. Stroke Width",
                    category: .effect)

        LibraryItem(base.chartSegments(colorSet: BasicColorSet()),
                    title: "Chart Segments ColorSet",
                    category: .effect)

        LibraryItem(base.chartLegend(style: DefaultLegendStyle()),
                    title: "Chart Legend",
                    category: .layout)

        // Interaction

        LibraryItem(base.onChartSegmentTapGesture({ datum in }),
                    title: "Chart Segment: Tap",
                    category: .layout)

        LibraryItem(base.onChartSegmentMomentaryTouchGesture({ datum in }),
                    title: "Chart Segment: Touch Momentary",
                    category: .layout)


    }

}
