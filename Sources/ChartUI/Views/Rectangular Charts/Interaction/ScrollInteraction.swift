//
//  ScrollInteraction.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/23/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
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
