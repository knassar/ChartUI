//
//  Range+Presets.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import Foundation

extension Range {

    public static var today: Range<Date> {
        .today..<Date.today.dayAfter
    }

    public static var previousWeek: Range<Date> {
        Calendar.current.date(byAdding: .day, value: -7, to: .today)!.dayStart..<Date.today.dayAfter
    }

    public static var previousMonth: Range<Date> {
        Calendar.current.date(byAdding: .month, value: -1, to: .today)!.dayStart..<Date.today.dayAfter
    }

    public static var previousYear: Range<Date> {
        Calendar.current.date(byAdding: .year, value: -1, to: .today)!.dayStart..<Date.today.dayAfter
    }

}

// MARK: - Helpers

// MARK: Date Helpers

extension Date {

    var dayStart: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self))!
    }

    var dayBefore: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: dayStart)!.dayStart
    }

    var dayAfter: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!.dayStart
    }

    var timeIntervalOfDay: TimeInterval {
        timeIntervalSinceReferenceDate - dayStart.timeIntervalSinceReferenceDate
    }

    static func today(at timeIntervalOfDay: TimeInterval) -> Date {
        Date().dayStart.addingTimeInterval(timeIntervalOfDay)
    }

    static var today: Date {
        Date().dayStart
    }

}

// MARK: TimeInterval Helpers

extension TimeInterval {


    static func t(_ hour: Int, _ minutes: Int = 0) -> TimeInterval {
        TimeInterval(hour) * Self.minutes(60) + Self.minutes(minutes)
    }

    static func minutes(_ minutes: Int) -> TimeInterval {
        TimeInterval(minutes * 60)
    }

    static func days(_ days: Int) -> TimeInterval {
        TimeInterval(days) * Self.t(24)
    }

}

