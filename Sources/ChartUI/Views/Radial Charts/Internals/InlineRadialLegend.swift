//
//  InlineRadialLegend.swift
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

struct InlineRadialLegend: View {

    var legendStyle: InlineLegendStyle

    @Environment(\.radialChartLayout)
    var layout: RadialChartLayout

    var body: some View {
        ZStack {
            ForEach(layout.segments, id: \.datum.id) { segment in
                HStack {
                    if let name = legendStyle.name(for: segment.datum) {
                        Text(name)
                            .font(legendStyle.font ?? .caption)
                            .foregroundColor(legendStyle.foregroundColor ?? .black)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                            .shadow(color: .white, radius: 1, x: 0.0, y: 0.0)

                    }
                }
                .offset(x: labelX(for: segment),
                        y: labelY(for: segment))
            }
            .frame(width: layout.localFrame.width, height: layout.localFrame.height)
        }
    }

    private func labelX(for segment: RadialChartLayout.Segment) -> CGFloat {
        labelPoint(for: segment).x - layout.localFrame.center.x
    }

    private func labelY(for segment: RadialChartLayout.Segment) -> CGFloat {
        labelPoint(for: segment).y - layout.localFrame.center.y
    }

    private func labelPoint(for segment: RadialChartLayout.Segment) -> CGPoint {
        let radius: CGFloat
        switch segment.sweep.degrees {
        case ...10:
            radius = segment.outerRadius * 1.25
        default:
            radius = segment.outerRadius * 1.12
        }
        return segment.bisectorPoint(at: radius)
    }

}

struct InlineRadialLegend_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            PieChart(data: sampleCalendarData)
                .chartInsets(.horizontal, 50)
                .chartSegments(strokeWidth: 1)
//                .radialChart(projection: 20, for: sampleCalendarData.data[8].id)
//                .radialChart(outerRadius: .proportional)
                .chartLegend(style: InlineLegendStyle())
            Spacer()
        }
        .padding(.all)
    }
}
