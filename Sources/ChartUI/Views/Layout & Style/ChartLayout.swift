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

    public var insets: EdgeInsets = EdgeInsets()

    public var localFrame = CGRect.zero

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

    init(insetEdges: Edge.Set, length: CGFloat?) where StyleValue == Never {
        self.modifier = { style in
            var style = style
            if insetEdges.contains(.top) {
                style.insets.top = length ?? 0
            }
            if insetEdges.contains(.bottom) {
                style.insets.bottom = length ?? 0
            }
            if insetEdges.contains(.leading) {
                style.insets.leading = length ?? 0
            }
            if insetEdges.contains(.trailing) {
                style.insets.trailing = length ?? 0
            }
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

    public func chartInsets(_ insets: EdgeInsets) -> some View {
        self.modifier(ChartLayoutWrapper(value: insets, keyPath: \.insets))
    }

    public func chartInsets(_ edges: Edge.Set = .all, _ length: CGFloat? = 8) -> some View {
        self.modifier(ChartLayoutWrapper(insetEdges: edges, length: length))
    }

    public func chartInsets(_ length: CGFloat?) -> some View {
        self.modifier(ChartLayoutWrapper(insetEdges: .all, length: length))
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
