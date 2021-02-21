//
//  RadialLegend.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct RadialLegend: View {

    @Environment(\.categorizedDataStyle)
    var categorizedData: CategorizedDataStyle

    var body: some View {
        switch categorizedData.legendStyle {
        case let .some(inline as InlineLegendStyle):
            InlineRadialLegend(legendStyle: inline)
        case let .some(standAlone as StandAloneLegendStyle):
            StandAloneLegend(legendStyle: standAlone)
        default:
            EmptyView()
        }
    }
}
