//
//  Bar.swift
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

protocol BarShape: InsettableShape {

    var segment: RectangularChartLayout.Segment { get }

    init(segment: RectangularChartLayout.Segment)

}

extension BarShape {

    func inset(by amount: CGFloat) -> some InsettableShape {
        return self
    }

}

struct Bar<Shape: BarShape>: View {

    var datum: AnyCategorizedDatum
    var shape: Shape.Type

    @Environment(\.categorizedDataStyle)
    var style: CategorizedDataStyle

    @Environment(\.rectangularChartLayout)
    var layout: RectangularChartLayout

    var body: some View {
        if let segmentLayout = layout.segment(at: datum.index), segmentLayout.isValid {
            shape.init(segment: segmentLayout)
                .strokeBorder(stroke, lineWidth: strokeWidth)
                .background(shape.init(segment: segmentLayout).fill(fill))
        }
    }

    private var fill: Color {
        style.fill(for: datum)
    }

    private var stroke: Color {
        style.stroke(for: datum)
    }

    private var strokeWidth: CGFloat {
        style.strokeWidth(for: datum)
    }

}

struct RectBar: BarShape {

    var segment: RectangularChartLayout.Segment

    var animatableData: RectangularChartLayout.Segment.AnimatableData {
        get { segment.animatableData }
        set { segment.animatableData = newValue }
    }

    init(segment: RectangularChartLayout.Segment) {
        self.segment = segment
    }

    func path(in rect: CGRect) -> Path {
        Path(segment.rect)
    }

}

struct Bar_Previews: PreviewProvider {
    static var previews: some View {
        let data = sampleCalendarData
        GeometryReader { geometry in
            RectangularChartLayoutComposer(data: data, geometry: geometry) {
                Bar(datum: data.categorizedData[0], shape: RectBar.self)
                Bar(datum: data.categorizedData[3], shape: RectBar.self)
                Bar(datum: data.categorizedData[6], shape: RectBar.self)
                Bar(datum: data.categorizedData[9], shape: RectBar.self)
            }
        }
        .chartInsets(.all, 20)
        .border(Color.gray)
        .frame(width: 200, height: 200)
    }
}
