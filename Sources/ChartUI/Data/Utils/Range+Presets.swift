//
//  Range+Presets.swift
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

