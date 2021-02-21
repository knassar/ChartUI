//
//  LineChartStyle.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct LineChartStyleKey: EnvironmentKey {
    static let defaultValue: LineChartStyle = LineChartStyle()
}

extension EnvironmentValues {

    public var lineChartStyle: LineChartStyle {
        get {
            self[LineChartStyleKey.self]
        }
        set {
            self[LineChartStyleKey.self] = newValue
        }
    }

}

public struct LineChartStyle {

    public fileprivate(set) var color: Color = .blue
    public fileprivate(set) var lineWidth: CGFloat = 2
    public fileprivate(set) var lineEdge: Color? = nil
    public fileprivate(set) var lineEdgeWidth: CGFloat = 1
    
}

private struct LineChartStyleWrapper<StyleValue>: ViewModifier {

    @Environment(\.lineChartStyle)
    private var currentStyle: LineChartStyle

    var modifier: (LineChartStyle) -> LineChartStyle

    init(value: StyleValue, keyPath: WritableKeyPath<LineChartStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            style[keyPath: keyPath] = value
            return style
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.lineChartStyle, modifier(currentStyle))
    }

}

// MARK: - Line Chart Style Modifiers

extension View {

    /// Sets the line color for a `LineChart`
    /// - Parameter color: the color for the line
    /// - Returns: A modified view
    public func lineChart(lineColor color: Color) -> some View {
        self.modifier(LineChartStyleWrapper(value: color, keyPath: \.color))
    }

    /// Sets an outline color for a `LineChart` line
    /// - Parameter color: the color with which to outline the line
    /// - Returns: A modified view
    public func lineChart(lineEdgeColor color: Color?) -> some View {
        self.modifier(LineChartStyleWrapper(value: color, keyPath: \.lineEdge))
    }

    /// Sets the width of the outline stroke
    /// - Parameter lineEdgeWidth: width in points for the outline stroke
    /// - Returns: A modified view
    public func lineChart(lineEdgeWidth: CGFloat) -> some View {
        self.modifier(LineChartStyleWrapper(value: lineEdgeWidth, keyPath: \.lineEdgeWidth))
    }

    /// Sets the line width for a `LineChart`
    /// - Parameter lineWidth: width in points for the line
    /// - Returns: A modified view
    public func lineChart(lineWidth: CGFloat) -> some View {
        self.modifier(LineChartStyleWrapper(value: lineWidth, keyPath: \.lineWidth))
    }

}

struct LineChartStyle_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: AnyView) -> [LibraryItem] {

        LibraryItem(base.lineChart(lineColor: .blue),
                    title: "Line Chart Line Color",
                    category: .effect)

        LibraryItem(base.lineChart(lineEdgeColor: .white),
                    title: "Line Chart Edge Color",
                    category: .effect)

        LibraryItem(base.lineChart(lineEdgeWidth: 1.0),
                    title: "Line Chart Edge Width",
                    category: .effect)

        LibraryItem(base.lineChart(lineWidth: 1.0),
                    title: "Line Chart Line Width",
                    category: .effect)

    }

}
