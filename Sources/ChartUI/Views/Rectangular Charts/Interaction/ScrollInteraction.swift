//
//  ScrollInteraction.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/23/21.
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

struct ScrollInteraction: ViewModifier {

    var offset: Binding<CGFloat>

    @Environment(\.lineChartLayout)
    private var layout: LineChartLayout

    @Environment(\.lineChartStyle)
    private var lineChartStyle: LineChartStyle

    @State
    private var scrollGestureState = ScrollGesture.State()

    func body(content: Content) -> some View {
        content
            .gesture(ScrollGesture(offset: offset,
                                   state: $scrollGestureState,
                                   isEnabled: lineChartStyle.scrollEnabled,
                                   layout: layout))
    }

}

extension View {

    func attachScrollInteraction(with offsetBinding: Binding<CGFloat>) -> some View {
        self.modifier(ScrollInteraction(offset: offsetBinding))
    }

}

struct ScrollGesture: Gesture {

    @Binding
    private var scrollOffset: CGFloat

    @Binding
    private var state: State

    private var isEnabled: Bool

    private var layout: LineChartLayout

    init(offset: Binding<CGFloat>, state: Binding<State>, isEnabled: Bool, layout: LineChartLayout) {
        self._scrollOffset = offset
        self._state = state
        self.isEnabled = isEnabled
        self.layout = layout
    }

    var body: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged(scrollChanged(_:))
            .onEnded(scrollEnded(_:))
    }

    var maxOverscroll: CGFloat {
        (layout.localFrame.width / 2) / max(layout.localFrame.width / 2, layout.maxScrollOffset)
    }

    private func scrollChanged(_ value: DragGesture.Value) {
        guard isEnabled else { return }
        if state.offsetAtGestureStart.isNaN {
            state.offsetAtGestureStart = layout.scrollOffset
        }
        let deltaFromStart = state.offsetAtGestureStart - value.translation.width / layout.maxScrollOffset
        scrollOffset = min(max(0 - maxOverscroll, deltaFromStart), 1 + maxOverscroll)
    }

    private func scrollEnded(_ value: DragGesture.Value) {
        guard isEnabled else { return }
        if value.translation.width == 0 {
            switch value.startLocation.x {
            case layout.localFrame.minX...16:
                scrollOffset = 0
            case (layout.localFrame.maxX - 16)...:
                scrollOffset = 1
            default:
                break
            }
        } else {
            scrollOffset = min(max(0, scrollOffset), 1)
        }
        state.offsetAtGestureStart = .nan
    }

    struct State {
        var offsetAtGestureStart = CGFloat.nan
    }

}
