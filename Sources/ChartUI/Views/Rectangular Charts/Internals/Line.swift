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
    var fill: Bool = false

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
        var last = first
        segment.points.dropFirst().forEach {
            path.addLine(to: $0)
            last = $0
        }

        if fill {
            path.addLine(to: CGPoint(x: last.x, y: segment.rect.maxY))
            path.addLine(to: CGPoint(x: first.x, y: segment.rect.maxY))
            path.closeSubpath()
            return path
        } else {
            return path
                .strokedPath(StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        }
    }

}
