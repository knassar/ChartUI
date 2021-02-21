//
//  Line.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/21/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct Line: InsettableShape {

    var segment: LineChartLayout.Segment
    var width: CGFloat

    var id: CGFloat { segment.id }

    func inset(by amount: CGFloat) -> some InsettableShape {
        self
    }

    var animatableData: LineChartLayout.Segment.AnimatableData {
        get { segment.animatableData }
        set { segment.animatableData = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = segment.points.first else { return path }

        path.move(to: first)
        segment.points.dropFirst().forEach { path.addLine(to: $0) }

        return path
            .strokedPath(StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

}
