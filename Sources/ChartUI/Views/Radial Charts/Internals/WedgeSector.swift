//
//  WedgeSector.swift
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

struct WedgeSector: SectorShape {

    var segment: RadialChartLayout.Segment

    var animatableData: RadialChartLayout.Segment.AnimatableData {
        get { segment.animatableData }
        set { segment.animatableData = newValue }
    }

    init(segment: RadialChartLayout.Segment) {
        self.segment = segment
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: segment.center, radius: segment.outerRadius, startAngle: segment.startAngle, endAngle: segment.endAngle, clockwise: false)
        path.addLine(to: segment.center)
        path.closeSubpath()
        return path
    }

}
