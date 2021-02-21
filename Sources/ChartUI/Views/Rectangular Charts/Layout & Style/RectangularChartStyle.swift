//
//  RectangularChartStyle.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct RectangularChartStyleKey: EnvironmentKey {
    static let defaultValue: RectangularChartStyle = RectangularChartStyle()
}

extension EnvironmentValues {

    public var rectangularChartStyle: RectangularChartStyle {
        get {
            self[RectangularChartStyleKey.self]
        }
        set {
            self[RectangularChartStyleKey.self] = newValue
        }
    }

}

public struct RectangularChartStyle {

    public fileprivate(set) var xAxisGrid: XAxisGrid? = nil
    public fileprivate(set) var yAxisGrid: YAxisGrid? = nil

    public fileprivate(set) var xOriginMark: OriginMark? = .line(width: 1)
    public fileprivate(set) var yOriginMark: OriginMark? = .line(width: 1)
    public fileprivate(set) var xOriginColor: Color?
    public fileprivate(set) var yOriginColor: Color?

    public fileprivate(set) var rangeFill: Color? = Color.blue.opacity(0.2)
    public fileprivate(set) var rangeStroke: Color? = nil
    public fileprivate(set) var rangeStrokeWidth: CGFloat = 0.5

}

private struct RectangularChartStyleWrapper<StyleValue>: ViewModifier {

    @Environment(\.rectangularChartStyle)
    private var currentStyle: RectangularChartStyle

    var modifier: (RectangularChartStyle) -> RectangularChartStyle

    init(value: StyleValue, keyPath: WritableKeyPath<RectangularChartStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            style[keyPath: keyPath] = value
            return style
        }
    }

    init(modifier: @escaping (RectangularChartStyle) -> RectangularChartStyle) where StyleValue == Never {
        self.modifier = modifier
    }

    func body(content: Content) -> some View {
        content.environment(\.rectangularChartStyle, modifier(currentStyle))
    }

}

// MARK: - Rectangular Chart Style Modifiers

extension View {

    /// Sets the Y axis grid configuration
    /// - Parameter grid: A grid configuration
    /// - Returns: A modified view
    public func rectChart(yAxisGrid grid: YAxisGrid?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: grid, keyPath: \.yAxisGrid))
    }

    /// Sets the X axis grid configuration
    /// - Parameter grid: A grid configuration
    /// - Returns: A modified view
    public func rectChart(xAxisGrid grid: XAxisGrid?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: grid, keyPath: \.xAxisGrid))
    }

}

// MARK: - Rectangular Chart Origin Style Modifiers

extension View {

    /// Sets the origin mark style for the Y origin
    /// - Parameter mark: An origin mark
    /// - Returns: A modified view
    public func rectChart(yOriginMark mark: OriginMark?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: mark, keyPath: \.yOriginMark))
    }

    /// Sets the origin color for the Y origin mark
    /// - Parameter color: A color
    /// - Returns: A modified view
    public func rectChart(yOriginColor color: Color?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: color, keyPath: \.yOriginColor))
    }

    /// Sets the origin mark style for the X origin
    /// - Parameter mark: An origin mark
    /// - Returns: A modified view
    public func rectChart(xOriginMark mark: OriginMark?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: mark, keyPath: \.xOriginMark))
    }

    /// Sets the origin color for the X origin mark
    /// - Parameter color: A color
    /// - Returns: A modified view
    public func rectChart(xOriginColor color: Color?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: color, keyPath: \.xOriginColor))
    }

    /// Sets the origin mark style for the both origin markers
    /// - Parameter mark: An origin mark
    /// - Returns: A modified view
    public func rectChart(originMark mark: OriginMark?) -> some View {
        self.modifier(RectangularChartStyleWrapper(modifier: { style in
            var style = style
            style[keyPath: \.xOriginMark] = mark
            style[keyPath: \.yOriginMark] = mark
            return style
        }))
    }

    /// Sets the origin color for both origin marks
    /// - Parameter color: A color
    /// - Returns: A modified view
    public func rectChart(originColor color: Color?) -> some View {
        self.modifier(RectangularChartStyleWrapper(modifier: { style in
            var style = style
            style[keyPath: \.xOriginColor] = color
            style[keyPath: \.yOriginColor] = color
            return style
        }))
    }

}

// MARK: - Rectangular Chart Range Highlight Style Modifiers

extension View {

    /// Sets the fill color for a rectangular range decorator
    /// - Parameter fill: a fill color
    /// - Returns: A modified view
    public func rectChartRange(fill: Color?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: fill, keyPath: \.rangeFill))
    }

    /// Sets the stroke color for a rectangular range decorator boundaries
    /// - Parameter stroke: a stroke color
    /// - Returns: A modified view
    public func rectChartRange(stroke: Color?) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: stroke, keyPath: \.rangeStroke))
    }

    /// Sets the stroke width in points for a rectangular range decorator boundaries
    /// - Parameter strokeWidth: a stroke width in points
    /// - Returns: A modified view
    public func rectChartRange(strokeWidth: CGFloat) -> some View {
        self.modifier(RectangularChartStyleWrapper(value: strokeWidth, keyPath: \.rangeStrokeWidth))
    }

}

struct RectangularChartStyle_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: AnyView) -> [LibraryItem] {

        // grids
        LibraryItem(base.rectChart(xAxisGrid: XAxisGrid(spacing: 10)),
                    title: "Rect Chart X-Axis Grid",
                    category: .other)

        LibraryItem(base.rectChart(yAxisGrid: YAxisGrid(spacing: 10)),
                    title: "Rect Chart Y-Axis Grid",
                    category: .other)

        // origins
        LibraryItem(base.rectChart(yOriginMark: .line(width: 1)),
                    title: "Rect Chart Y-Origin Mark",
                    category: .effect)

        LibraryItem(base.rectChart(yOriginColor: .red),
                    title: "Rect Chart Y-Origin Color",
                    category: .effect)

        LibraryItem(base.rectChart(xOriginMark: .line(width: 1)),
                    title: "Rect Chart X-Origin Mark",
                    category: .effect)

        LibraryItem(base.rectChart(xOriginColor: .green),
                    title: "Rect Chart X-Origin Color",
                    category: .effect)

        LibraryItem(base.rectChart(originMark: .line(width: 1)),
                    title: "Rect Chart Origin Mark",
                    category: .effect)

        LibraryItem(base.rectChart(originColor: .gray),
                    title: "Rect Chart Origin Color",
                    category: .effect)

        // ranges
        LibraryItem(base.rectChartRange(fill: Color.blue.opacity(0.2)),
                    title: "Rect Chart Range Fill Color",
                    category: .effect)

        LibraryItem(base.rectChartRange(stroke: .blue),
                    title: "Rect Chart Range Stroke Color",
                    category: .effect)

        LibraryItem(base.rectChartRange(strokeWidth: 1),
                    title: "Rect Chart Range Stroke Width",
                    category: .effect)

    }

}
