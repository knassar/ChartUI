//
//  OrderedData.swift
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
