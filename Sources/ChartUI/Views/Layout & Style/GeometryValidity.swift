//
//  GeometryValidity.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

extension CGPoint {

    var isValid: Bool {
        x.isValid && y.isValid
    }

    static let invalid = CGPoint(x: CGFloat.nan, y: .nan)

}

extension CGSize {

    var isValid: Bool {
        width.isValid && height.isValid
    }

    static let invalid = CGSize(width: CGFloat.nan, height: .nan)

}

extension CGRect {

    var isValid: Bool {
        origin.isValid && size.isValid
    }

    static let invalid = CGRect(origin: .invalid, size: .invalid)

}

extension Angle {

    var isValid: Bool {
        !degrees.isNaN
    }

    static let invalid = Angle(degrees: .nan)

}

extension CGFloat {

    var isValid: Bool {
        !self.isNaN
    }

}

