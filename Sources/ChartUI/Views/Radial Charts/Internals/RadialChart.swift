//
//  RadialChart.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

protocol SectorShape: InsettableShape {

    var segment: RadialChartLayout.Segment { get }

    init(segment: RadialChartLayout.Segment)

}

extension SectorShape {

    func inset(by amount: CGFloat) -> some InsettableShape {
        return self
    }

}

struct RadialChart<Sector: SectorShape, Underlay: View, Overlay: View>: View {

    private var data: AnyCategorizedDataSeries

    private var sectorShape: Sector.Type

    private var underlay: Underlay?

    private var overlay: Overlay?

    @Environment(\.categorizedDataStyle)
    var categorizedData: CategorizedDataStyle

    init(data: AnyCategorizedDataSeries, sectorShape: Sector.Type, underlay: Underlay?, overlay: Overlay?) {
        self.data = data
        self.sectorShape = sectorShape
        self.underlay = underlay
        self.overlay = overlay
    }

    var body: some View {
        GeometryReader { geometry in
            RadialChartLayoutComposer(data: data, geometry: geometry) {
                ZStack {
                    if let underlay = underlay {
                        underlay
                    }
                    ForEach(zOrderedDatums) {
                        RadialSector(datum: $0, shape: sectorShape)
                            .animation(.default)
                    }
                    if let overlay = overlay {
                        overlay
                    }
                    RadialLegend()
                        .animation(.default)
                }
            }
            .drawingGroup()
        }
    }

    private var zOrderedDatums: [AnyCategorizedDatum] {
        data.categorizedData.sorted { categorizedData.zIndex(for: $0) < categorizedData.zIndex(for: $1) }
    }

}
