//
//  PointHighlightStyle.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct PointHighlightStyleKey: EnvironmentKey {
    static let defaultValue: PointHighlightStyle = PointHighlightStyle()
}

extension EnvironmentValues {

    public var pointHighlightStyle: PointHighlightStyle {
        get {
            self[PointHighlightStyleKey.self]
        }
        set {
            self[PointHighlightStyleKey.self] = newValue
        }
    }

}

public struct PointHighlightStyle {

    public fileprivate(set) var fill: Color? = .blue
    public fileprivate(set) var stroke: Color? = nil
    public fileprivate(set) var strokeWidth: CGFloat = 0.5
    public fileprivate(set) var radius: CGFloat = 3

}

private struct PointHighlightStyleWrapper<StyleValue>: ViewModifier {

    @Environment(\.pointHighlightStyle)
    private var currentStyle: PointHighlightStyle

    var modifier: (PointHighlightStyle) -> PointHighlightStyle

    init(value: StyleValue, keyPath: WritableKeyPath<PointHighlightStyle, StyleValue>) {
        self.modifier = { style in
            var style = style
            style[keyPath: keyPath] = value
            return style
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.pointHighlightStyle, modifier(currentStyle))
    }

}

// MARK: - Rectangular Chart Point Highlight Style Modifiers

extension View {

    /// Set the fill color for PointHighlight decorators
    /// - Parameter fill: a fill color
    /// - Returns: A modified view
    public func chartPointHighlight(fill: Color?) -> some View {
        self.modifier(PointHighlightStyleWrapper(value: fill, keyPath: \.fill))
    }

    /// Set the stroke color for PointHighlight decorators
    /// - Parameter stroke: a fill color
    /// - Returns: A modified view
    public func chartPointHighlight(stroke: Color?) -> some View {
        self.modifier(PointHighlightStyleWrapper(value: stroke, keyPath: \.stroke))
    }

    /// Set the strokeWidth in points for PointHighlight decorators
    /// - Parameter strokeWidth: a stroke width in points
    /// - Returns: A modified view
    public func chartPointHighlight(strokeWidth: CGFloat) -> some View {
        self.modifier(PointHighlightStyleWrapper(value: strokeWidth, keyPath: \.strokeWidth))
    }

    /// Set the radius for PointHighlight decorators
    /// - Parameter radius: radius in points
    /// - Returns: A modified view
    public func chartPointHighlight(radius: CGFloat) -> some View {
        self.modifier(PointHighlightStyleWrapper(value: radius, keyPath: \.radius))
    }

}
