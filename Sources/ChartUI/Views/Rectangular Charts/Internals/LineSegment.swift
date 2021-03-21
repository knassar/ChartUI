//
//  LineSegment.swift
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

struct LineSegment: InsettableShape {

    var start: CGPoint
    var end: CGPoint

    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        self
    }

    typealias AnimatableData = AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData>

    var animatableData: AnimatableData {
        get {
            AnimatablePair(start.animatableData, end.animatableData)
        }
        set {
            self.start.animatableData = newValue.first
            self.end.animatableData = newValue.second
        }
    }

}
