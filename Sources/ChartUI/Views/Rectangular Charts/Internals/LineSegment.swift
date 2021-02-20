//
//  LineSegment.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
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
