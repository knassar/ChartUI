//
//  RadialSector.swift
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

struct RadialSector<Shape: SectorShape>: View {

    var datum: AnyCategorizedDatum
    var shape: Shape.Type

    @Environment(\.categorizedDataStyle)
    var style: CategorizedDataStyle

    @Environment(\.radialChartLayout)
    var layout: RadialChartLayout

    var body: some View {
        if let segmentLayout = layout.segment(at: datum.index), segmentLayout.isValid {
            shape.init(segment: segmentLayout)
                .strokeBorder(stroke, style: StrokeStyle(lineWidth: strokeWidth, lineJoin: .round))
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

struct RadialSector_Previews: PreviewProvider {
    static var previews: some View {
        let data = sampleCalendarData
        GeometryReader { geometry in
            RadialChartLayoutComposer(data: data, geometry: geometry) {
                Circle()
                    .frame(width: 2)
                RadialSector(datum: data.categorizedData[0], shape: RingSector.self)
                RadialSector(datum: data.categorizedData[2], shape: WedgeSector.self)
            }
        }
        .border(Color.gray)
        .frame(width: 200, height: 200)

    }
}
