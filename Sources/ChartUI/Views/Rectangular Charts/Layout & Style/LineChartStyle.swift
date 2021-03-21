//
//  LineChartStyle.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2019 HungryMelonStudios LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//      http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
    public fileprivate(set) var lineFill: Fill = .none
    public fileprivate(set) var lineWidth: CGFloat = 2
    public fileprivate(set) var lineEdge: Color? = nil
    public fileprivate(set) var lineEdgeWidth: CGFloat = 1

    var scrollEnabled: Bool = false
    var scrollOffsetBinding: Binding<CGFloat>?

    /// A fill style for the area under the line
    public enum Fill {
        case color(Color)
        case gradient(LinearGradient)
        case none
    }

}

public protocol LineFill {
    var lineFill: LineChartStyle.Fill { get }
}

extension Color: LineFill {

    public var lineFill: LineChartStyle.Fill { .color(self) }

}

extension Gradient: LineFill {

    public var lineFill: LineChartStyle.Fill { .gradient(LinearGradient(gradient: self, startPoint: .top, endPoint: .bottom)) }

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

    init(modifier: @escaping (LineChartStyle) -> LineChartStyle) where StyleValue == Never {
        self.modifier = modifier
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

    /// Sets a gradient fill style for the area under the line in a `LineChart`
    ///
    /// Because the `LineChart` data layout is computed & rendered in horizontal tiling segments, only vertical linear gradients are currently supported. The gradient supplied will always be converted to a `LinearGradient` with a `startPoint: .top` and `endPoint: .bottom`.
    ///
    /// - Parameter fill: the base gradient to use to form a top-to-bottom `LinearGradient` for the area under the line.
    /// - Returns: A modified view
    public func lineChart(fill: Gradient?) -> some View {
        return self.modifier(LineChartStyleWrapper(value: fill?.lineFill ?? .none, keyPath: \.lineFill))
    }

    /// Sets the solid fill color for the area under the line in a `LineChart`
    /// - Parameter fill: the color for the area under the line
    /// - Returns: A modified view
    public func lineChart(fill: Color?) -> some View {
        return self.modifier(LineChartStyleWrapper(value: fill?.lineFill ?? .none, keyPath: \.lineFill))
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

// MARK: - Line Chart Scroll Modifiers

extension View {

    /// Activates scrolling interaction for the modified `LineChart`s
    ///
    /// When scrolling is enabled for a `LineChart`, dragging across the content of the chart will scroll the visible range of the chart over the absolute extents of the data. Areas at each end of the chart will also respond to touches, scrolling the chart to the absolute start or end of the available data, respectively.
    ///
    /// Use this modifier to activate scrolling for a chart when you don't want access to or control over the scroll position. If you need to associate the scroll offset of the affected chart with another view (such as a `ScrollThumb` decorator), use `lineChart(scrollOffset:enabled:)` instead.
    ///
    /// This modifier can also be used to deactivate scrolling on a chart which has previously been activated
    /// - Parameter scrollEnabled: A boolean for activating or deactivating scrolling on a chart
    /// - Returns: A modified view
    public func lineChart(scrollEnabled: Bool) -> some View {
        self.modifier(LineChartStyleWrapper(value: scrollEnabled, keyPath: \.scrollEnabled))
    }

    /// Activates scrolling interaction for the modified `LineChart`s
    ///
    /// When scrolling is enabled for a `LineChart`, dragging across the content of the chart will scroll the visible range of the chart over the absolute extents of the data. Areas at each end of the chart will also respond to touches, scrolling the chart to the absolute start or end of the available data, respectively.
    ///
    /// This modifier activates scrolling for a chart, binding the chart's scrollOffset to the provided value.
    /// The scroll offset is given in terms of a percentage over the absolute data range, allowing application of the scroll value to views outside of the chart's particular layout. For example, by assigning the same `scrollOffset` binding to two charts showing similar data, their scrolling will be synchronized.
    /// Because the `scrollOffset` binding is read/write, you can use this modifier to enable scrolling while also observing and controlling the scroll position of the affected chart. This can be used to associate the chart's scroll position with an auxiliary navigation aid, such as a `ScrollThumb` decorator, or displaying different data states in an adjacent view based on the scrolled position.
    /// - Parameters:
    ///   - scrollOffset: A binding to a `CGFloat` value between `0` and `1`.
    ///   - enabled: An optional boolean to enable or disable direct scrolling gestures. Defaults to true.
    /// - Returns: A modified view.
    public func lineChart(scrollOffset: Binding<CGFloat>? = nil, enabled: Bool = true) -> some View {
        self.modifier(LineChartStyleWrapper(modifier: { style in
            var style = style
            style.scrollEnabled = enabled
            style.scrollOffsetBinding = scrollOffset
            return style
        }))
    }

}

struct LineChartStyle_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: AnyView) -> [LibraryItem] {

        LibraryItem(base.lineChart(lineColor: .blue),
                    title: "Line Chart Line Color",
                    category: .effect)

        LibraryItem(base.lineChart(fill: .blue),
                    title: "Line Chart Fill Color",
                    category: .effect)
        LibraryItem(base.lineChart(fill: Gradient(colors: [.white, .blue])),
                    title: "Line Chart Fill Gradient",
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


        // Interactions

        LibraryItem(base.lineChart(scrollEnabled: true),
                    title: "Line Chart - Scroll - Simple",
                    category: .effect)

        LibraryItem(base.lineChart(scrollOffset: .constant(1)),
                    title: "Line Chart - Scroll w/ Binding",
                    category: .effect)

    }

}
