//
//  InlineRectangularLegend.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct InlineRectangularLegend: View {

    var legendStyle: InlineLegendStyle

    @Environment(\.rectangularChartLayout)
    var layout: RectangularChartLayout

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
                    }
                }
                .frame(width: labelWidth(for: segment), height: labelHeight(for: segment))
                .offset(x: labelX(for: segment),
                        y: labelY(for: segment))
            }
            .frame(width: layout.localFrame.width, height: layout.localFrame.height)
        }
    }

    private func labelWidth(for segment: RectangularChartLayout.Segment) -> CGFloat {
        segment.rect.width
    }

    private func labelHeight(for segment: RectangularChartLayout.Segment) -> CGFloat {
        24
    }

    private func labelX(for segment: RectangularChartLayout.Segment) -> CGFloat {
        segment.rect.midX - layout.localFrame.center.x
    }

    private func labelY(for segment: RectangularChartLayout.Segment) -> CGFloat {
        segment.rect.maxY - layout.localFrame.center.y + labelHeight(for: segment) / 2
    }

}

extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}

struct InlineRectangularLegend_Previews: PreviewProvider {

    static let data = sampleQuarters

    static var previews: some View {
        BarChart(data: data, underlay: ZStack {
            ForEach(Array(stride(from: 10, through: Int(data.maximum.yValue), by: 20)), id: \.self) { y in
                YAxisRange(y...y + 10)
            }
        })
        .rectChart(yAxisGrid: YAxisGrid(spacing: 10))
        .chartLegend(style: InlineLegendStyle())
        .chartInsets(.all, 20)
        .padding(.vertical)
        .frame(height: 300)
        .border(Color.gray)
    }

}
