//
//  StringExtension.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 29/08/2023.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
