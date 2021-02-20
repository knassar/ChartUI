//
//  Line.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct Line: Shape {

    var width: CGFloat

    @Environment(\.linearChartLayout)
    var layout: LinearChartLayout

    func path(in rect: CGRect) -> Path {
        path
            .strokedPath(StrokeStyle(lineWidth: width, lineJoin: .round))
    }

    private var path: Path {
        var path = Path()
        let points = layout.visibleDataPoints.map { $0 }
        guard let first = points.first else { return path }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        return path
    }

}

struct Line_Previews: PreviewProvider {

    static let data = sampleTimeSeries

    static var previews: some View {
        HStack {
            GeometryReader { geometry in
                LinearChartLayoutComposer(data: data, geometry: geometry, xRange: nil) {
                    Line(width: 1)
                }
            }
            .lineChart(lineWidth: 2)
            .frame(width: 200, height: 80)
            VStack {
                Text("\(data.maximum.yValue)")
                Spacer()
                Text("\(data.minimum.yValue)")
            }
            .foregroundColor(.red)
            .frame(width: 100, height: 100)
        }
    }
}
