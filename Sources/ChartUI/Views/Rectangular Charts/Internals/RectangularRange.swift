//
//  RectangularRange.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

struct RectangularRange: InsettableShape {

    var rangeRect: CGRect

    init(_ rangeRect: CGRect) {
        self.rangeRect = rangeRect
    }

    func path(in rect: CGRect) -> Path {
        Path(rangeRect)
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        self
    }

    typealias AnimatableData = CGRect.AnimatableData

    var animatableData: AnimatableData {
        get {
            rangeRect.standardized.animatableData
        }
        set {
            self.rangeRect.animatableData = newValue
        }
    }

}
