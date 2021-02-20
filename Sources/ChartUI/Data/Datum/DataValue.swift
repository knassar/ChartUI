//
//  DataValue.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

/// A value which may be visualized in a chart
public protocol DataValue: Comparable {

    /// The data value represented as a scalar value for transform into the chart coordinates
    var dataSeriesValue: CGFloat { get }

    /// The absolute minimum possible value of this type
    static var absoluteMinimum: Self { get }

    /// The absolute maximum possible value of this type
    static var absoluteMaximum: Self { get }

}

extension Double: DataValue {

    public var dataSeriesValue: CGFloat { CGFloat(self) }

    public static var absoluteMinimum: Self { -Double.greatestFiniteMagnitude }

    public static var absoluteMaximum: Self { Double.greatestFiniteMagnitude }

}

extension Date: DataValue {

    public var dataSeriesValue: CGFloat { CGFloat(timeIntervalSinceReferenceDate) }

    public static var absoluteMinimum: Self { Date.distantPast }

    public static var absoluteMaximum: Self { Date.distantFuture }

}

extension Int: DataValue {

    public var dataSeriesValue: CGFloat { CGFloat(self) }

    public static var absoluteMinimum: Self { Int.min }

    public static var absoluteMaximum: Self { Int.max }

}

