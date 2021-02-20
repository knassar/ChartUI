//
//  OrderedData.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct OrderedDataKey: EnvironmentKey {
    static let defaultValue: OrderedData = OrderedData()
}

extension EnvironmentValues {

    public var orderedData: OrderedData {
        get {
            self[OrderedDataKey.self]
        }
        set {
            self[OrderedDataKey.self] = newValue
        }
    }

}

public struct OrderedData {

    public fileprivate(set) var data: AnyDataSeries = EmptyDataSeries()


}

private struct OrderedDataWrapper<StyleValue>: ViewModifier {

    @Environment(\.orderedData)
    private var current: OrderedData

    var modifier: (OrderedData) -> OrderedData

    init(value: StyleValue, keyPath: WritableKeyPath<OrderedData, StyleValue>) {
        self.modifier = { style in
            var style = style
            style[keyPath: keyPath] = value
            return style
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.orderedData, modifier(current))
    }

}

// MARK: Data Setup

extension View {

    func orderedChartData(_ data: AnyDataSeries) -> some View {
        self.modifier(OrderedDataWrapper(value: data, keyPath: \.data))
    }

}
