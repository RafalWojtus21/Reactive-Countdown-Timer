//
//  DateFormatterExtension.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import Foundation

extension DateFormatter {
    
    enum DateFormat: String {
        case dayMonth = "dd MMMM"
        case hourMinute = "HH:mm"
    }
    static var dayMonthStringDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dayMonth.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()

    static var hourMinuteDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.hourMinute.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
}
