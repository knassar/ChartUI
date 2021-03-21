//
//  Line.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/21/21.
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
