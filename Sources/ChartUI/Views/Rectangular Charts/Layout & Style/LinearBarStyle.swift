//
//  LinearBarStyle.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct LinearBarsStyleKey: EnvironmentKey {
    static let defaultValue: LinearBarsStyle = LinearBarsStyle()
}

extension EnvironmentValues {

    public var linearBarsStyle: LinearBarsStyle {
        get {
            self[LinearBarsStyleKey.self]
        }
        set {
            self[LinearBarsStyleKey.self] = newValue
        }
    }

}

public struct LinearBarsStyle {

    public fileprivate(set) var spacing: LinearBarsStyle.BarWidth = .auto
    public fileprivate(set) var orientation: LinearBarsStyle.Orientation = .horizontal

    var defaultValues = LinearBarStyle()
    var segments = [AnyHashable: LinearBarStyle]()

    public func width(for datum: AnyCategorizedDatum) -> LinearBarsStyle.BarWidth {
        segments[datum.id]?.width ?? defaultValues.width ?? .auto
    }

    public enum BarWidth: Equatable {
        case auto,
             constant(CGFloat)
    }

    public enum Orientation {
        case horizontal, vertical
    }

}

struct LinearBarStyle {

    public var width: LinearBarsStyle.BarWidth?

}

private struct LinearBarsStyleWrapper<StyleValue>: ViewModifier {

    @Environment(\.linearBarsStyle)
    private var current: LinearBarsStyle

    var modifier: (LinearBarsStyle) -> LinearBarsStyle

    init(segmentId: AnyHashable, value: StyleValue, keyPath: WritableKeyPath<LinearBarStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            var values = style.segments[segmentId] ?? LinearBarStyle()
            values[keyPath: keyPath] = value
            style.segments[segmentId] = values
            return style
        }
    }

    init(segmentValue: StyleValue, keyPath: WritableKeyPath<LinearBarStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            style.defaultValues[keyPath: keyPath] = segmentValue
            return style
        }
    }

    init(value: StyleValue, keyPath: WritableKeyPath<LinearBarsStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            style[keyPath: keyPath] = value
            return style
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.linearBarsStyle, modifier(current))
    }

}

// MARK: - Bar Chart General Style Modifiers

extension View {

    // TODO
//    public func barChart(orientation: LinearBarsStyle.Orientation) -> some View {
//        self.modifier(LinearBarsStyleWrapper(value: orientation, keyPath: \.orientation))
//    }


    /// Sets the spacing between bars for a `BarChart`
    ///
    /// A spacing of `.auto` divides the space remaining between bars after accounting for the widths of the bars
    /// - Parameter barSpacing: the spacing between bars. Defaults to `.auto`
    /// - Returns: A modified view
    public func barChart(barSpacing: LinearBarsStyle.BarWidth) -> some View {
        self.modifier(LinearBarsStyleWrapper(value: barSpacing, keyPath: \.spacing))
    }

    /// Sets the spacing to a fixed width between bars for a `BarChart`
    /// - Parameter barSpacing: the spacing in points between bars
    /// - Returns: A modified view
    public func barChart(barSpacing: CGFloat) -> some View {
        self.modifier(LinearBarsStyleWrapper(value: .constant(barSpacing), keyPath: \.spacing))
    }

}

// MARK: - Bar Chart Default Segment Style Modifiers

extension View {

    /// Sets the width of all bars for a `BarChart`
    ///
    /// A width of `.auto` divides 80% of the available width remaining between each bar after accounting for the widths of any bars with constant widths
    /// - Parameter width: the width of each bar. Defaults to `.auto`
    /// - Returns: A modified view
    public func barChart(width: LinearBarsStyle.BarWidth) -> some View {
        self.modifier(LinearBarsStyleWrapper(segmentValue: width, keyPath: \.width))
    }

    /// Sets the width of all bars for a `BarChart`
    /// - Parameter width: the width of each bar in points.
    /// - Returns: A modified view
    public func barChart(width: CGFloat) -> some View {
        self.modifier(LinearBarsStyleWrapper(segmentValue: .constant(width), keyPath: \.width))
    }

}

// MARK: - Bar Chart Segment-Specific Segment Style Modifiers

extension View {

    /// Sets the width of the specified bar for a `BarChart`
    /// - Parameter width: the width of the bar. Defaults to `.auto`
    /// - Parameter segmentId:  the `Id` of the datum for which to set width
    /// - Returns: A modified view
    public func barChart<ID: Hashable>(width: LinearBarsStyle.BarWidth, for segmentId: ID) -> some View {
        self.modifier(LinearBarsStyleWrapper(segmentId: AnyHashable(segmentId), value: width, keyPath: \.width))
    }

    /// Sets the width of the specified bar for a `BarChart`
    /// - Parameter width: the width of the bar in points
    /// - Parameter segmentId:  the `Id` of the datum for which to set width
    /// - Returns: A modified view
    public func barChart<ID: Hashable>(width: CGFloat, for segmentId: ID) -> some View {
        self.modifier(LinearBarsStyleWrapper(segmentId: AnyHashable(segmentId), value: .constant(width), keyPath: \.width))
    }

}
