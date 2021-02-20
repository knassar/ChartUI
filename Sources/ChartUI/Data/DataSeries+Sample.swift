//
//  DataSeries+Sample.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
//

import SwiftUI

let sampleTimeSeries: DataSeries<TimeSeriesDatum<Double>> = {
    var data: [TimeSeriesDatum<Double>] = [.point(0, at: .today)]
    for d in 0..<99 {
        let date = Calendar.current.date(byAdding: .day, value: -(d + 1), to: .today(at: seed[d].time))!
        data.append(.point(seed[d].value, at: date))
    }

    return DataSeries(data: data + [
        .point(68, at: .today(at: .t(8))),
    ])
}()

let sampleShortTimeSeries = DataSeries(data: [
    TimeSeriesDatum.point(0, at: Date().dayStart.dayBefore.dayBefore.dayBefore),
    TimeSeriesDatum.point(10, at: Date().dayStart.dayBefore.dayBefore),
    TimeSeriesDatum.point(20, at: Date().dayStart.dayBefore),
    TimeSeriesDatum.point(30, at: .today),
])

private func calendarData(offset: Int = 0) -> DataSeries<IdentifiedValueDatum<String, Int>> {
    var seeds = seed.dropFirst(offset)
    let data: [IdentifiedValueDatum<String, Int>] = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
    ].map { .count(Int(seeds.removeFirst().value), for: $0) }
    return DataSeries(data: data)
}

let sampleCalendarData = calendarData()
let sampleCalendarData2 = calendarData(offset: 12)

let sampleCalendarDataNameMapper: LegendNameMapper = { datum in
    switch datum.id as? String {
    case "Jan":
        return "January"
    case "Feb":
        return "February"
    case "Mar":
        return "March"
    case "Apr":
        return "April"
    case "May":
        return "May"
    case "Jun":
        return "June"
    case "Jul":
        return "July"
    case "Aug":
        return "August"
    case "Sep":
        return "Septempber"
    case "Oct":
        return "October"
    case "Nov":
        return "November"
    case "Dec":
        return "December"
    default:
        return nil
    }
}

let sampleQuarters: DataSeries<IdentifiedValueDatum<String, Int>> = {
    var seeds = seed
    seeds.removeFirst(8)
    var data: [IdentifiedValueDatum<String, Int>] = [
        "Q1",
        "Q2",
        "Q3",
        "Q4",
    ].map { .count(Int(seeds.removeFirst().value), for: $0) }

    return DataSeries(data: data)
}()

private let seed: [(value: Double, time: TimeInterval)] = [(43.0, 61200.0), (123.0, 61200.0), (33.0, 28800.0), (147.0, 7200.0), (41.0, 64800.0), (12.0, 72000.0), (27.0, 54000.0), (36.0, 36000.0), (76.0, 43200.0), (127.0, 14400.0), (60.0, 43200.0), (58.0, 21600.0), (39.0, 72000.0), (117.0, 54000.0), (72.0, 72000.0), (10.0, 3600.0), (75.0, 68400.0), (56.0, 32400.0), (63.0, 10800.0), (23.0, 46800.0), (102.0, 64800.0), (53.0, 3600.0), (79.0, 18000.0), (23.0, 43200.0), (92.0, 18000.0), (10.0, 21600.0), (144.0, 32400.0), (81.0, 50400.0), (63.0, 50400.0), (56.0, 28800.0), (136.0, 57600.0), (75.0, 72000.0), (14.0, 10800.0), (78.0, 10800.0), (98.0, 3600.0), (48.0, 43200.0), (124.0, 3600.0), (148.0, 72000.0), (113.0, 46800.0), (52.0, 46800.0), (137.0, 46800.0), (92.0, 36000.0), (22.0, 3600.0), (103.0, 39600.0), (147.0, 25200.0), (54.0, 39600.0), (30.0, 50400.0), (43.0, 43200.0), (23.0, 36000.0), (66.0, 64800.0), (33.0, 61200.0), (144.0, 46800.0), (141.0, 18000.0), (146.0, 18000.0), (50.0, 18000.0), (50.0, 54000.0), (95.0, 7200.0), (60.0, 61200.0), (82.0, 57600.0), (102.0, 54000.0), (120.0, 57600.0), (94.0, 50400.0), (28.0, 57600.0), (7.0, 54000.0), (35.0, 54000.0), (78.0, 10800.0), (110.0, 64800.0), (8.0, 18000.0), (61.0, 54000.0), (10.0, 50400.0), (52.0, 50400.0), (105.0, 54000.0), (107.0, 39600.0), (1.0, 50400.0), (38.0, 57600.0), (112.0, 43200.0), (35.0, 54000.0), (62.0, 3600.0), (98.0, 68400.0), (137.0, 61200.0), (3.0, 39600.0), (94.0, 3600.0), (143.0, 18000.0), (75.0, 21600.0), (123.0, 36000.0), (121.0, 36000.0), (90.0, 46800.0), (112.0, 50400.0), (6.0, 50400.0), (10.0, 25200.0), (32.0, 43200.0), (127.0, 10800.0), (150.0, 54000.0), (101.0, 10800.0), (104.0, 68400.0), (105.0, 50400.0), (146.0, 14400.0), (36.0, 68400.0), (45.0, 57600.0), (60.0, 43200.0)]


struct Temperature: Comparable {
    var celsius: Double
    var fahrenheit: Double {
        celsius * 1.8 + 32
    }

    init(celsius: Double) {
        self.celsius = celsius
    }

    init(fahrenheit: Double) {
        self.celsius = (fahrenheit - 32) * 1.8
    }

    static func < (lhs: Temperature, rhs: Temperature) -> Bool {
        lhs.celsius < rhs.celsius
    }
}

extension Temperature: DataValue {
    var dataSeriesValue: CGFloat {
        CGFloat(celsius)
    }
    static var absoluteMinimum: Self {
        Temperature(celsius: -273.15) // absolute zero
    }
    static var absoluteMaximum: Self {
        Temperature(celsius: .greatestFiniteMagnitude)
    }
}


let tooHot = Temperature(celsius: 32)

let tooCold = Temperature(celsius: 18)

func dataSeries(for timeTemp: [Date: Temperature]) -> DataSeries<TimeSeriesDatum<Temperature>> {

    DataSeries(data: timeTemp.map { TimeSeriesDatum.point($0.value, at: $0.key) } )

}

let tempSeed: [(value: Double, time: TimeInterval)] = [(23.0, 61200.0), (33.0, 61200.0), (31.0, 28800.0), (41.0, 7200.0), (38.0, 64800.0), (22.0, 72000.0), (27.0, 54000.0), (33.0, 36000.0), (16.0, 43200.0), (12.0, 14400.0), (8.0, 43200.0), (9.0, 21600.0), (4.0, 72000.0), (17.0, 54000.0), (21.0, 72000.0), (10.0, 3600.0), (15.0, 68400.0), (12.0, 32400.0), (13.0, 10800.0), (23.0, 46800.0)]

let timeTemp: [Date: Temperature] = {
    var timeTemp = [Date: Temperature]()
    for d in 0..<12 {
        let date = Calendar.current.date(byAdding: .day, value: -(d + 1), to: .today(at: tempSeed[d].time))!
        timeTemp[date] = Temperature(celsius: tempSeed[d].value)
    }
    return timeTemp
}()
