//
//  FinishedSession.swift.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import Foundation

struct FinishedSessionPlan: Equatable {
    var sessions: [CodeReviewSession]
    let startTime: Date
    let finishTime: Date
}
