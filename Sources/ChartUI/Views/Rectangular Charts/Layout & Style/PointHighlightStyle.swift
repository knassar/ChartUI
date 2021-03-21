//
//  PointHighlightStyle.swift
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
