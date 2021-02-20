//
//  RingSector.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct RingSector: SectorShape {

    var segment: RadialChartLayout.Segment

    var animatableData: RadialChartLayout.Segment.AnimatableData {
        get { segment.animatableData }
        set { segment.animatableData = newValue }
    }

    init(segment: RadialChartLayout.Segment) {
        self.segment = segment
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: segment.center, radius: segment.outerRadius, startAngle: segment.startAngle, endAngle: segment.endAngle, clockwise: false)
        path.addArc(center: segment.center, radius: segment.innerRadius, startAngle: segment.endAngle, endAngle: segment.startAngle, clockwise: true)
        path.closeSubpath()
        return path

    }

}
