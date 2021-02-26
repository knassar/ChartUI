//
//  ChartLayout.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct ChartLayoutKey: EnvironmentKey {
    static let defaultValue: ChartLayout = ChartLayout()
}

extension EnvironmentValues {

    public var chartLayout: ChartLayout {
        get {
            self[ChartLayoutKey.self]
        }
        set {
            self[ChartLayoutKey.self] = newValue
        }
    }

}

public struct ChartLayout {

    /// The calculated local frame of the chart, after the chart-specific layout has been computed
    public var localFrame = CGRect.zero

    /// The calculated insets for the chart, after all modifiers are applied
    public var insets: EdgeInsets {
        EdgeInsets(
            top: insetEdge(.top) ?? insetEdge(.vertical) ?? insetEdge(.all) ?? 0,
            leading: insetEdge(.leading) ?? insetEdge(.horizontal) ?? insetEdge(.all) ?? 0,
            bottom: insetEdge(.bottom) ?? insetEdge(.vertical) ?? insetEdge(.all) ?? 0,
            trailing: insetEdge(.trailing) ?? insetEdge(.horizontal) ?? insetEdge(.all) ?? 0
        )
    }

    fileprivate var insetEdges = [Int8: CGFloat]()

    private func insetEdge(_ edge: Edge.Set) -> CGFloat? {
        insetEdges[edge.rawValue]
    }

}

private struct ChartLayoutWrapper<StyleValue>: ViewModifier {

    @Environment(\.chartLayout)
    private var currentStyle: ChartLayout

    var modifier: (ChartLayout) -> ChartLayout

    init(value: StyleValue, keyPath: WritableKeyPath<ChartLayout, StyleValue>) {
        self.modifier = { style in
            var style = style
            style[keyPath: keyPath] = value
            return style
        }
    }

    init(edges: Edge.Set, length: CGFloat) where StyleValue == Never {
        self.modifier = { style in
            var style = style
            style.insetEdges[edges.rawValue] = length
            return style
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.chartLayout, modifier(currentStyle))
    }

}

// MARK: - Chart Layout Modifiers

extension View {

    func chartLayout(localFrame: CGRect) -> some View {
        self.modifier(ChartLayoutWrapper(value: localFrame, keyPath: \.localFrame))
    }

}

// MARK:  Radial Chart Insets

extension View {

    /// Sets in-set padding between the outer edges of the chart View and the chart data.
    ///
    /// This modifier works like the standard `padding(_:)` modifier except that it adds space between the chart data and its view's boundaries. Decorators such as grids, markers, origin marks, etc will continue to be rendered within that space.
    /// Instead of affecting the size of the chart view, `insets` are subtracted from the overall size of the chart, leaving less available space for chart data, which will be compressed to fit in the remaining space.
    /// - Parameter insets: An EdgeInsets defining inset padding for the chart
    /// - Returns: A modified view
    public func chartInsets(_ insets: EdgeInsets) -> some View {
        let edges = [
            Edge.Set.top.rawValue: insets.top,
            Edge.Set.bottom.rawValue: insets.bottom,
            Edge.Set.leading.rawValue: insets.leading,
            Edge.Set.trailing.rawValue: insets.trailing,
        ]
        return self.modifier(ChartLayoutWrapper(value: edges, keyPath: \.insetEdges))
    }

    /// Sets in-set padding between the outer edges of the chart View and the chart data.
    ///
    /// This modifier works like the standard `padding(_:)` modifier except that it adds space _between_ the chart data and its view's boundaries. Decorators such as grids, markers, origin marks, etc will continue to be rendered within that space.
    /// Instead of affecting the size of the chart view, `insets` are subtracted from the overall size of the chart, leaving less available space for chart data, which will be compressed to fit in the remaining space.
    ///
    /// Like the `padding(_:_:)` modifier, this modifier can be stacked to apply dififerent values to different edges, with the more-specific declarations overriding the less-specific, such as:
    /// ```
    /// .chartInsets(.all, 8)
    /// .chartInsets(.horizontal, 20)
    /// .chartInsets(.top, 40)
    ///
    /// // insets will be equivalent to:
    /// //    EdgeInsets(top: 40, leading: 20, bottom: 8, trailing: 20)
    /// ```
    /// - Parameters:
    ///   - edges: Edge.Set options identifying which edges to apply inset padding to. Defaults to `.all`
    ///   - length: The amount of space, in points, for each specified edge. Defaults to `8.0`
    /// - Returns: A modified view
    public func chartInsets(_ edges: Edge.Set = .all, _ length: CGFloat = 8) -> some View {
        self.modifier(ChartLayoutWrapper(edges: edges, length: length))
    }

    /// Sets in-set padding between the outer edges of the chart View and the chart data.
    ///
    /// This modifier works like the standard `padding(_:)` modifier except that it adds space between the chart data and its view's boundaries. Decorators such as grids, markers, origin marks, etc will continue to be rendered within that space.
    /// Instead of affecting the size of the chart view, `insets` are subtracted from the overall size of the chart, leaving less available space for chart data, which will be compressed to fit in the remaining space.
    /// - Parameter length: An inset value in points to be applied to all edges
    /// - Returns: A modified view.
    public func chartInsets(_ length: CGFloat) -> some View {
        self.modifier(ChartLayoutWrapper(edges: .all, length: length))
    }

}

struct ChartLayout_LibraryContent: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: AnyView) -> [LibraryItem] {

        LibraryItem(base.chartInsets(EdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)),
                    title: "Chart Insets - by EdgeInsets",
                    category: .layout)

        LibraryItem(base.chartInsets(.all, 10.0),
                    title: "Chart Insets - by Edge",
                    category: .layout)

        LibraryItem(base.chartInsets(10.0),
                    title: "Chart Insets - Uniform",
                    category: .layout)
    }

}
