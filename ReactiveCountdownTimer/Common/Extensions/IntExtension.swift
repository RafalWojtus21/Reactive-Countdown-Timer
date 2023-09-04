//
//  IntExtension.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 04/09/2023.
//

import Foundation

extension Int {
    static func calculateFormattedDuration(duration: Int) -> String {
        typealias L = Localization.General
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        formatter.unitOptions = .providedUnit

        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60

        var components: [String] = []

        if hours > 0 {
            let hoursMeasurement = Measurement(value: Double(hours), unit: UnitDuration.hours)
            components.append(formatter.string(from: hoursMeasurement))
        }

        if minutes > 0 {
            let minutesMeasurement = Measurement(value: Double(minutes), unit: UnitDuration.minutes)
            components.append(formatter.string(from: minutesMeasurement))
        }

        let secondsMeasurement = Measurement(value: Double(seconds), unit: UnitDuration.seconds)
        components.append(formatter.string(from: secondsMeasurement))

        return components.joined(separator: " ")
    }
}

