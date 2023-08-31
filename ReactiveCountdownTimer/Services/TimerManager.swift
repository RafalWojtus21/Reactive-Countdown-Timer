//
//  CalendarService.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 29/08/2023.
//

import Foundation
import RxSwift
import RxRelay

protocol HasTimerManager {
    var timerManager: TimerManager { get }
}

protocol TimerManager {
}

final class TimerManagerImpl: TimerManager {
    
    // MARK: Properties

    private let bag = DisposeBag()
    
    // MARK: Initialization
    
    init() {}

    // MARK: Public Implementation

    // MARK: Private Implementation
}
