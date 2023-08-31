//
//  LoggerExtension.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 29/08/2023.
//

import Foundation
import OSLog
typealias Log = Logger

extension Logger {
    // swiftlint:disable:next force_unwrapping
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    static let timer = Logger(subsystem: subsystem, category: "Timer")
}
