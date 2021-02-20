//
//  RadialSector.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
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
